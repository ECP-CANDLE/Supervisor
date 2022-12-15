library(data.table)
library(ggplot2)

results_dir <- '/home/nick/Documents/results/cp1/non_nci_hpo_log'

dt <- fread(paste0(results_dir, '/all_counts.csv'), col.names = c("ts", "count"))
dt$hour <- (dt$ts - min(dt$ts)) / 60 / 60
fwrite(all_dt, file=paste0(results_dir, '/counts_all.csv'), row.names = F)


fs <- Sys.glob(paste0(results_dir, '/*_counts.csv'))

dts = list()
i = 1
for (f in fs) {
  if (! endsWith(f, 'all_counts.csv')) {
    hpo_dt <- fread(f, col.names = c("ts", "count"))
    hpo_dt$hour <- (hpo_dt$ts - min(hpo_dt$ts)) / 60 / 60
    fname = basename(f)
    hpo_dt$hpo_id <- strsplit(fname, "_", fixed=T)[[1]][1]
    dts[[i]] <- hpo_dt
    i = i + 1
  }
}

all_dt <- do.call(rbind, dts)
dt$hpo_id <- 'all'
all_dt <- rbind(all_dt, dt)

all_dt[hpo_id == 1 & (count == 1 | count == 0)]

ggplot(data=all_dt, mapping=aes(x=hour, y=count, color=hpo_id)) +
  geom_line() +
  xlab("Hours") +
  ylab("Run Counts")







fwrite(all_dt, file="/home/nick/Documents/repos/Supervisor/workflows/cp1/scripts/counts_by_hpo.csv", row.names = F)
head(all_dt)


ggplot(data=all_dt[hpo_id == 1]) +
  geom_bar(mapping = aes(x=hour, fill=count))

se <- fread("/home/nick/Documents/repos/Supervisor/workflows/cp1/scripts/start_end.csv", col.names =c("start", "end", "hpo_id"))
ggplot (se, aes(x=start, y=hpo_id)) +
  geom_segment(
    xend=se$end, yend=se$hpo_id,
    size = 3
  ) +
  xlab('time (minutes)') +
  ylab('hpo id') +
  scale_x_continuous(limits = c(0, max(se$end)))


ft <- fread("~/Documents/results/cp1/train_upf_timings.csv")
ft$time_per_epoch <- ft$total_train_time / ft$epochs
fwrite(ft, file="~/Documents/results/cp1/train_upf_timings.csv", row.names = F)

agg_ft <- ft[, .(min(total_train_time), max(total_train_time), mean(total_train_time), sd(total_train_time),
        min(epochs), max(epochs), mean(epochs), sd(epochs),
        min(time_per_epoch), max(time_per_epoch), mean(time_per_epoch), sd(time_per_epoch)), by=model_name]
setnames(agg_ft, c("model_name", "min_train_time", "max_train_time", "mean_train_time", "std_train_time", "min_epochs",
                   "max_epochs", "mean_epochs", "std_epochs", "min_time_per_epoch", "max_time_per_epoch", "mean_time_per_epoch", "std_time_per_epoch"))
fwrite(agg_ft, file="~/Documents/results/cp1/agg_timings_by_model.csv", row.names = F)


idt <- fread("~/Documents/results/cp1/inference_results.csv")
agg_idt <- idt[, .(min(r2), max(r2), mean(r2), sd(r2),
                 min(mae), max(mae), mean(mae), sd(mae),
                 min(mse), max(mse), mean(mse), sd(mse)), by=model_class]
setnames(agg_idt, c("model_class", "min_r2", "max_r2", "mean_r2", "std_r2", "min_mae",
                   "max_mae", "mean_mae", "std_mae", "min_mse", "max_mse", "mean_mse", "std_mse"))
fwrite(agg_idt, file="~/Documents/results/cp1/agg_inference_results_by_model_class.csv", row.names = F)




##################
# Combine HPO logs files adding hpo_id and iteration
###################

results_dir <- '~/Documents/results/cp1/non_nci_hpo_log/'
fs <- Sys.glob(paste0(results_dir, '/*_hpo_runs.txt'))

dts = list()
i = 1

for (f in fs) {
  hpo_dt <- fread(f, col.names = c("run_id", 'xcorr_record_id', 'params', 'instance_dir', 'timestamp', 'val_loss'),
                  sep="|")
  fname = basename(f)
  vals <- strsplit(fname, "_", fixed=T)
  hpo_dt$hpo_id <- strtoi(vals[[1]][1])
  hpo_dt$iteration <- strtoi(vals[[1]][2])
  dts[[i]] <- hpo_dt
  i = i + 1
}

results_dir <- '~/Documents/results/cp1/nci_hpo_log/'
fs <- Sys.glob(paste0(results_dir, '/*_hpo_runs.txt'))
for (f in fs) {
  hpo_dt <- fread(f, col.names = c("run_id", 'xcorr_record_id', 'params', 'instance_dir', 'timestamp', 'val_loss'),
                  sep="|")
  fname = basename(f)
  vals <- strsplit(fname, "_", fixed=T)
  hpo_dt$hpo_id <- strtoi(vals[[1]][1]) + 20
  hpo_dt$iteration <- strtoi(vals[[1]][2])
  dts[[i]] <- hpo_dt
  i = i + 1
}


hpos <- do.call(rbind, dts)

fwrite(hpos, file="~/Documents/results/cp1/all_hpos.txt", row.names = F, sep='|', quote=F)

####################
# HPO Iteration plot

ggplot(data=hpos[val_loss < 1e+03], mapping=aes(x=iteration, y=val_loss)) +
  geom_point(alpha=0.25) +
  xlim(c("1", "2", "3")) +
  xlab("HPO Iteration") +
  ylab("Val Loss (log scale)") +
  scale_y_continuous(trans='log10') +
  facet_wrap(~ hpo_id, ncol=5)
