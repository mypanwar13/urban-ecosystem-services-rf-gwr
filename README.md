# Earth Observation-Based Urban Ecosystem Services in Delhi, India

R scripts for Random Forest (RF) and Geographically Weighted Regression (GWR) analysis of carbon storage and sequestration (CSS) and urban stormwater retention (USWR) estimated using the InVEST model. The scripts examine environmental and anthropogenic driving factors influencing these ecosystem services in Delhi, India.

## Overview

This repository contains R scripts associated with an Earth Observation-based assessment of urban ecosystem services in Delhi. The analyses use InVEST-derived ecosystem-service outputs and spatial driving factors to investigate variable importance and spatial relationships.

## Scripts

### 1. Carbon Storage and Sequestration (CSS)

**File:** `CSS_Driving_Factors_RF_GWR.R`

This script performs Random Forest analysis to assess the importance of environmental and anthropogenic driving factors associated with InVEST-derived carbon storage and sequestration. It also fits a Geographically Weighted Regression (GWR) model to examine spatial variation in relationships between carbon storage and the driving factors.

### 2. Urban Stormwater Retention (USWR)

**File:** `USWR_Driving_Factors_RF_GWR.R`

This script performs Random Forest analysis to assess the importance of environmental and anthropogenic driving factors associated with InVEST-derived urban stormwater retention. It also fits a GWR model to examine spatial variation in these relationships.

## Methods

The scripts include:

- Random sampling of raster data
- Correlation matrix analysis
- Variance Inflation Factor (VIF) assessment
- Random Forest modelling with 1,000 trees
- Model evaluation using R² and RMSE on a 70:30 training–testing split
- Variable importance assessment
- GWR bandwidth selection using AICc
- Export of local GWR coefficients and summary statistics

## Software and Packages

The analyses were developed in R and use the following packages:

- `terra`
- `randomForest`
- `car`
- `GWmodel`
- `sp`

Install the required packages in R before running the scripts.

## Input Data

The scripts require the InVEST-derived carbon storage and sequestration or stormwater-retention raster, together with raster layers representing:

- Annual precipitation
- Elevation (DEM)
- Land surface temperature (LST)
- Slope
- Night-time lights (VIIRS)
- Population
- Distance to railways
- Distance to roads
- Distance to water bodies
- Distance to waterways

The input raster files are not included in this repository. The scripts currently contain local file paths that must be adapted to the locations of the corresponding input datasets.

## Outputs

Depending on the script, outputs include sampled data, correlation matrices, VIF results, Random Forest variable importance tables and plots, saved RF models, GWR local coefficients, and coefficient summary statistics.

## Reproducibility

A random seed of 123 is used for sampling and model-related randomisation. Reproducing the analyses requires the corresponding input rasters, compatible R packages, and appropriate spatial coordinate reference systems.

## Citation

If you use these scripts, please cite the associated research article once its publication details become available.
