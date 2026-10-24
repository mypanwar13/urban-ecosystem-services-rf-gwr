
library(terra)
library(randomForest)
library(car)
library(GWmodel)
library(sp)

# =====================================================
# 1. LOAD RASTERS
# =====================================================

carbon <- rast("H:/CSS 23/tot_c_fut2023.tif")

s <- c(
  carbon,
  rast("H:/Driving factors/Del_AnnualPpt_UTM.tif"),
  rast("H:/Driving factors/Del_DEM30_UTM.tif"),
  rast("H:/Driving factors/Del_MODISLST_UTM.tif"),
  rast("H:/Driving factors/Del_Slope_UTM.tif"),
  rast("H:/Driving factors/Del_VIIRS2023_UTM.tif"),
  rast("H:/Driving factors/Del_WorldPop2023_UTM.tif"),
  rast("H:/Driving factors/OSM_Del_raiways_Distance.tif"),
  rast("H:/Driving factors/OSM_Del_roads_Distance.tif"),
  rast("H:/Driving factors/OSM_Del_waterbodies_Distance.tif"),
  rast("H:/Driving factors/OSM_Del_waterways_Distance.tif")
)

names(s) <- c(
  "Carbon", "AnnualPpt", "DEM", "LST", "Slope",
  "VIIRS", "Pop", "RailDist", "RoadDist",
  "WaterBodyDist", "WaterWayDist"
)

# =====================================================
# 2. SAMPLE POINTS AND SPLIT DATA
# =====================================================

set.seed(123)

dat <- spatSample(
  s,
  size = 10000,
  method = "random",
  as.df = TRUE,
  na.rm = TRUE,
  xy = TRUE
)

write.csv(
  dat,
  "H:/Driving factors/Sampled_Data.csv",
  row.names = FALSE
)

set.seed(123)

sample_size <- floor(0.70 * nrow(dat))
train_ind <- sample(seq_len(nrow(dat)), size = sample_size)

train_data <- dat[train_ind, ]
test_data <- dat[-train_ind, ]

# =====================================================
# 3. CORRELATION MATRIX
# =====================================================

drivers <- dat[, c(
  "AnnualPpt", "DEM", "LST", "Slope", "VIIRS", "Pop",
  "RailDist", "RoadDist", "WaterBodyDist", "WaterWayDist"
)]

cor_mat <- cor(drivers)

write.csv(
  round(cor_mat, 3),
  "H:/Driving factors/Correlation_Matrix.csv"
)

print(round(cor_mat, 3))

# =====================================================
# 4. VARIANCE INFLATION FACTOR (VIF)
# =====================================================

vif_model <- lm(
  Carbon ~ AnnualPpt + DEM + LST + Slope +
    VIIRS + Pop + RailDist + RoadDist +
    WaterBodyDist + WaterWayDist,
  data = dat
)

vif_values <- vif(vif_model)

print(vif_values)

write.csv(
  data.frame(
    Variable = names(vif_values),
    VIF = vif_values
  ),
  "H:/Driving factors/VIF_Results.csv",
  row.names = FALSE
)

# =====================================================
# 5. RANDOM FOREST MODEL
# =====================================================

set.seed(123)

rf <- randomForest(
  Carbon ~ AnnualPpt + DEM + LST + Slope +
    VIIRS + Pop + RailDist + RoadDist +
    WaterBodyDist + WaterWayDist,
  data = train_data,
  ntree = 1000,
  importance = TRUE
)

print(rf)

# =====================================================
# 6. MODEL PERFORMANCE
# =====================================================

pred <- predict(rf, test_data)

R2 <- cor(test_data$Carbon, pred)^2
RMSE <- sqrt(mean((test_data$Carbon - pred)^2))

cat("\n=====================\n")
cat("MODEL PERFORMANCE\n")
cat("=====================\n")
cat("R2 =", round(R2, 4), "\n")
cat("RMSE =", round(RMSE, 4), "\n")

# =====================================================
# 7. VARIABLE IMPORTANCE
# =====================================================

imp <- importance(rf)

imp_df <- data.frame(
  Variable = rownames(imp),
  IncMSE = imp[, 1],
  IncNodePurity = imp[, 2]
)

imp_df <- imp_df[
  order(imp_df$IncMSE, decreasing = TRUE),
]

imp_df$ImportancePercent <- round(
  imp_df$IncMSE / sum(imp_df$IncMSE) * 100,
  2
)

print(imp_df)

write.csv(
  imp_df,
  "H:/Driving factors/RF_Importance.csv",
  row.names = FALSE
)

# =====================================================
# 8. VARIABLE IMPORTANCE PLOT
# =====================================================

png(
  "H:/Driving factors/RF_Importance.png",
  width = 1200,
  height = 900,
  res = 150
)

varImpPlot(
  rf,
  main = "Random Forest Variable Importance"
)

dev.off()

# =====================================================
# 9. SAVE RANDOM FOREST MODEL
# =====================================================

saveRDS(
  rf,
  "H:/Driving factors/RF_Model.rds"
)

cat("\nRandom Forest analysis completed.\n")

# =====================================================
# 10. GEOGRAPHICALLY WEIGHTED REGRESSION (GWR)
# =====================================================

dat_sp <- dat
coordinates(dat_sp) <- ~x+y

# 10.1 Optimal bandwidth selection using AICc

cat("\nCalculating optimal GWR bandwidth...\n")

bw <- bw.gwr(
  Carbon ~ AnnualPpt + DEM + LST + Slope +
    VIIRS + Pop + RailDist + RoadDist +
    WaterBodyDist + WaterWayDist,
  data = dat_sp,
  approach = "AICc",
  kernel = "gaussian",
  adaptive = TRUE
)

# 10.2 Fit GWR model

cat("\nFitting GWR model...\n")

gwr_model <- gwr.basic(
  Carbon ~ AnnualPpt + DEM + LST + Slope +
    VIIRS + Pop + RailDist + RoadDist +
    WaterBodyDist + WaterWayDist,
  data = dat_sp,
  bw = bw,
  kernel = "gaussian",
  adaptive = TRUE
)

# 10.3 Review model diagnostics and local coefficients

cat("\n=====================\n")
cat("GWR MODEL SUMMARY\n")
cat("=====================\n")

print(gwr_model)
print(summary(gwr_model$SDF))

coords <- sp::coordinates(gwr_model$SDF)

out <- cbind(
  X = coords[, 1],
  Y = coords[, 2],
  gwr_model$SDF@data
)

write.csv(
  out,
  "H:/Driving factors/GWR_Local_Coefficients.csv",
  row.names = FALSE
)

capture.output(
  summary(gwr_model$SDF),
  file = "H:/Driving factors/GWR_Coefficient_Summary.txt"
)

cat("\nGWR analysis completed.\n")
