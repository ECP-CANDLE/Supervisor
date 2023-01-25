import json

import h5py
import keras.backend as K
import numpy as np
from keras import optimizers
from keras.engine import topology
from keras.models import Sequential


def get_json_type(obj):
    """Serialize any object to a JSON-serializable structure.

    # Arguments
        obj: the object to serialize

    # Returns
        JSON-serializable structure representing `obj`.

    # Raises
        TypeError: if `obj` cannot be serialized.
    """
    # if obj is a serializable Keras class instance
    # e.g. optimizer, layer
    if hasattr(obj, "get_config"):
        return {
            "class_name": obj.__class__.__name__,
            "config": obj.get_config()
        }

    # if obj is any numpy type
    if type(obj).__module__ == np.__name__:
        return obj.item()

    # misc functions (e.g. loss function)
    if callable(obj):
        return obj.__name__

    # if obj is a python 'type'
    if type(obj).__name__ == type.__name__:
        return obj.__name__

    raise TypeError("Not JSON Serializable:", obj)


def convert_custom_objects(obj, custom_objects={}):
    """Handles custom object lookup.

    # Arguments
        obj: object, dict, or list.

    # Returns
        The same structure, where occurences
            of a custom object name have been replaced
            with the custom object.
    """
    if isinstance(obj, list):
        deserialized = []
        for value in obj:
            if value in custom_objects:
                deserialized.append(custom_objects[value])
            else:
                deserialized.append(value)
        return deserialized
    if isinstance(obj, dict):
        deserialized = {}
        for key, value in obj.items():
            if value in custom_objects:
                deserialized[key] = custom_objects[value]
            else:
                deserialized[key] = value
        return deserialized
    if obj in custom_objects:
        return custom_objects[obj]
    return obj


def save_optimizer(model, hdf_file):
    # from save_model in keras.models.py
    hdf_file.attrs["training_config"] = json.dumps(
        {
            "optimizer_config": {
                "class_name": model.optimizer.__class__.__name__,
                "config": model.optimizer.get_config(),
            },
            "loss": model.loss,
            "metrics": model.metrics,
            "sample_weight_mode": model.sample_weight_mode,
            "loss_weights": model.loss_weights,
        },
        default=get_json_type,
    ).encode("utf8")

    # Save optimizer weights.
    symbolic_weights = getattr(model.optimizer, "weights")
    if symbolic_weights:
        optimizer_weights_group = hdf_file.create_group("optimizer_weights")
        weight_values = K.batch_get_value(symbolic_weights)
        weight_names = []
        for i, (w, val) in enumerate(zip(symbolic_weights, weight_values)):
            # Default values of symbolic_weights is /variable for theano
            if K.backend() == "theano":
                if hasattr(w, "name") and w.name != "/variable":
                    name = str(w.name)
                else:
                    name = "param_" + str(i)
            else:
                if hasattr(w, "name") and w.name:
                    name = str(w.name)
                else:
                    name = "param_" + str(i)
            weight_names.append(name.encode("utf8"))

        optimizer_weights_group.attrs["weight_names"] = weight_names
        for name, val in zip(weight_names, weight_values):
            param_dset = optimizer_weights_group.create_dataset(name,
                                                                val.shape,
                                                                dtype=val.dtype)
            if not val.shape:
                # scalar
                param_dset[()] = val
            else:
                param_dset[:] = val


def load_optimizer(model, hdf_file):
    # instantiate optimizer
    training_config = hdf_file.attrs.get("training_config")

    training_config = json.loads(training_config.decode("utf-8"))
    optimizer_config = training_config["optimizer_config"]
    optimizer = optimizers.deserialize(optimizer_config, custom_objects={})

    # Recover loss functions and metrics.
    loss = convert_custom_objects(training_config["loss"])
    metrics = convert_custom_objects(training_config["metrics"])
    sample_weight_mode = training_config["sample_weight_mode"]
    loss_weights = training_config["loss_weights"]

    # Compile model.
    model.compile(
        optimizer=optimizer,
        loss=loss,
        metrics=metrics,
        loss_weights=loss_weights,
        sample_weight_mode=sample_weight_mode,
    )

    # Set optimizer weights.
    if "optimizer_weights" in hdf_file:
        # Build train function (to get weight updates).
        if isinstance(model, Sequential):
            model.model._make_train_function()
        else:
            model._make_train_function()
        optimizer_weights_group = hdf_file["optimizer_weights"]
        optimizer_weight_names = [
            n.decode("utf8")
            for n in optimizer_weights_group.attrs["weight_names"]
        ]
        optimizer_weight_values = [
            optimizer_weights_group[n] for n in optimizer_weight_names
        ]
        model.optimizer.set_weights(optimizer_weight_values)


def save_state(model, outdir, rank):
    fname = "{}/weights_opt_{}.h5".format(outdir, rank)
    with h5py.File(fname, "w") as f:
        model_weights_group = f.create_group("model_weights")
        topology.save_weights_to_hdf5_group(model_weights_group, model.layers)
        save_optimizer(model, f)
        f.flush()


def load_state(model, outdir, rank):
    fname = "{}/weights_opt_{}.h5".format(outdir, rank)

    # keras.engine.network.py, l. 1124+
    with h5py.File(fname, "r") as f:
        f = h5py.File(fname, mode="r")
        weights = f
        if "layer_names" not in f.attrs and "model_weights" in f:
            weights = f["model_weights"]

        topology.load_weights_from_hdf5_group(weights, model.layers)
        load_optimizer(model, f)
