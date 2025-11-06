# EV Proteomics MATLAB Scripts

This repository hosts two MATLAB templates used in our manuscript for extracellular vesicle (EV) proteomics:
- `ranklog_template.m` — rank–log₂ plot
- `mirrored_histogram_and_bland_altman_template.m` — mirrored histogram of log₂ ratios and a Bland–Altman comparison

Raw data: ProteomeXchange/PRIDE PXD063788.

## Requirements
- MATLAB R2022a+ (tested on R2024b)
- Statistics and Machine Learning Toolbox

## Quick start
```matlab
addpath(genpath('src'));

h = ranklog_template('TablePath','path/to/your_TMT_table.csv', ...
                     'Log2Col','Log2Ratio', 'PAdjCol','AdjPValue', ...
                     'GeneCol','GeneName', 'DescCol','GeneDescription', ...
                     'Alpha',0.05, 'OutPrefix','myTMT_ranklog');

[hHist, hBA, statsTbl] = mirrored_histogram_and_bland_altman_template( ...
                    'TablePath','path/to/your_LFQ_or_TMT_table.csv', ...
                    'Log2RatioCol','Log2RatioA', 'X1Col','Log2RatioA', 'X2Col','Log2RatioB', ...
                    'Bins',40, 'OutPrefix','myComp_ba_hist');
```

Outputs are written to `figures/` (PNG/SVG) and `tables/` (CSV).

## License
MIT (see `LICENSE`). Add this to source files:
```matlab
% SPDX-License-Identifier: MIT
```

## Citation
Cite this repo (Zenodo DOI: doi.org/10.5281/zenodo.17538223)


