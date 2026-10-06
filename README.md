# Feature selection and ensemble feature selection for fuzzy k-nearest neighbor classification

MATLAB code for the paper:

> Lohrmann, C., Lohrmann, A., Mailagaha Kumbure, M. (2025).
> On the benefit of feature selection and ensemble feature selection for fuzzy
> k-nearest neighbor classification. *Applied Soft Computing*, 171, 112784.
> https://doi.org/10.1016/j.asoc.2025.112784

Eight filter methods for feature selection and three function-perturbation
ensembles (intersection, mean rank, union) are compared against using no feature
selection, with the FKNN and MLPM-FKNN classifiers on twelve real-world data sets.

## Citation

If you use this code in your work, we kindly ask you to cite the paper above.

## Requirements

- MATLAB R2023b or newer
- Statistics and Machine Learning Toolbox

## Getting started

1. The data sets are not included in this repository. They are freely available
   from the sources listed in the article.
2. Set the MATLAB current folder to this repository folder.
3. Open `EFS_Ranking_application.m`, select a data set and run the script (F5).

The script performs the feature selection, evaluates the subsets with both fuzzy-KNN based
classifiers, and runs the statistical test.

### Setups

The shares of features follow the paper: 0.1 %, 1 %, 10 %, 25 % and 50 %, plus
80 % for the small data sets. The share of 1 (all features) is the "No FS"
benchmark and has to remain in the setup for the statistical tests.

## Repository structure

| Path | Contents |
|---|---|
| `EFS_Ranking_application.m` | Main script |
| `src/core/` | Feature selection procedure, evaluation, aggregation, result tables |
| `src/fs_methods/` | Individual filter methods |
| `src/classifiers/` | FKNN and MLPM-FKNN |
| `src/third_party/` | External code (see Credits) |
| `data/` | Data sets (not included; see the sources in the article) |

## Notes on the implementation

### Mutual Information and Symmetrical Uncertainty

The `muteinf` function from the "Feature Selection Library" (FSLib 2018) was used in the paper and
assumes class labels are coded as -1/+1. If class labels are coded as 1..K, as in this study,
MI and SU effectively measure the relevance of a feature to class 1 only.

Two versions are provided and selected via `miVersion` in the main script:

- `src/third_party/mi_original/` - unchanged functions; **reproduces the published results**
- `src/third_party/mi_corrected/` - all classes are counted, for any class labels

The corrected files differ from the originals in only two places, both marked
in the code. Everything else, including the binning, is unchanged.

### Other notes

- **Random seed.** The published results were produced without a fixed seed, so
  cross-validation splits differ between runs and results are comparable but not
  identical. Setting `rng(1)` in the main script makes a run reproducible.
- **FKNN tie handling.** Ties are included, but only ties at the smallest distance
  are counted, and the increased k is retained for the remaining test samples of a
  fold. Neighbors at distance zero receive a weight of 1, which can be smaller than
  the weights of other neighbors. This mainly affects very small feature subsets.

## Credits

This repository includes third-party and co-authored code. Please see the file
headers for the original authors and licenses, and cite the original sources
where appropriate.

- **FKNN** (`src/classifiers/fknn.m`) - Emre Akbas (2006), MATLAB Central File
  Exchange. Tie handling added by the authors of this study.
- **MLPM-FKNN** (`src/classifiers/mlpm_fknn_updated.m`, `pmean.m`) -
  Mahinda Mailagaha Kumbure. Original implementation:
  https://github.com/MahindaMK/Multi-local-Power-means-based-fuzzy-k-nearest-neighbor-algorithm-MLPM-FKNN
  Method introduced in: Mailagaha Kumbure, M., Luukka, P., Collan, M. (2019).
  An enhancement of fuzzy k-nearest neighbor classifier using multi-local power
  means. *EUSFLAT 2019*. https://doi.org/10.2991/eusflat-19.2019.13
- **muteinf / muteinf_MI** (`src/third_party/`) - Feature Selection Library,
  G. Roffo, MATLAB Central File Exchange.
- **Strife** (`src/fs_methods/`) - Lohrmann, C., Luukka, P. (2022).
  Nonspecificity, strife and total uncertainty in supervised feature selection.
  *Engineering Applications of Artificial Intelligence*, 109, 104628.
  Code: https://github.com/christophLUT/Nonspecificity-strife-and-total-uncertainty-in-supervised-feature-selection
- **Chi-squared test, MRMR, Pearson correlation and ReliefF** use the MATLAB
  built-in functions `fscchi2`, `fscmrmr`, `corrcoef` and `relieff`.


## License

MIT License (see `LICENSE`). Third-party code remains under its original license.

(This readme was created with the support of Claude Opus 5.5)
