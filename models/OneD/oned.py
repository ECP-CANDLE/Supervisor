import candle
import os

# Define any needed additional args to ensure all new args are command-line accessible.
additional_definitions = [{
    'name': 'x',
    'type': float,
    'nargs': 1,
    'help': '1D function, derived form cosine mixture'
}, {
    'name': 'new_keyword',
    'type': str,
    'nargs': 1,
    'help': 'helpful description'
}]

# Define args that are required.
required = None


# Extend candle.Benchmark to configure the args
class IBenchmark(candle.Benchmark):

    def set_locals(self):
        if required is not None:
            self.required = set(required)
        if additional_definitions is not None:
            self.additional_definitions = additional_definitions
