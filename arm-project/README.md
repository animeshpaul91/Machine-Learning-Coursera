# Positive and Negative Association Rule Mining (PNAR)

A MATLAB implementation of association rule mining algorithms for discovering both positive and negative correlations in transaction datasets using correlation threshold and dual confidence approaches.

**Author:** Animesh Paul
**Created:** May 2015

## Overview

This project implements three association rule mining algorithms:

1. **Traditional Apriori** - Discovers positive association rules only
2. **Traditional PNAR** - Extends Apriori to find both positive and negative rules
3. **Improved PNAR** - Enhanced version with correlation threshold monitoring and dual confidence approach

### What are Positive and Negative Association Rules?

Association rules express relationships between items in a dataset:

- **Positive Rules**: `A => B` (if A is present, B is likely present)
- **Negative Rules**:
  - `~A => ~B` (if A is absent, B is likely absent)
  - `~A => B` (if A is absent, B is likely present)
  - `A => ~B` (if A is present, B is likely absent)

### Applications

- Market basket analysis
- Customer behavior prediction
- Network link prediction (finding missing links in graphs)
- Transaction pattern analysis

## Project Structure

```
PNAR Project/
├── Algorithm Scripts
│   ├── Apriori.m                  # Traditional Apriori algorithm
│   ├── Pnar.m                     # Traditional PNAR algorithm
│   ├── Pnar_improved.m            # Improved PNAR with correlation threshold
│   ├── Pnar1.m                    # Alternative PNAR version
│   ├── Pnar_improved1.m           # Alternative improved PNAR
│   ├── findRulesapriori.m         # Rule extraction for Apriori
│   ├── FindRulesPnar.m            # Rule extraction for improved PNAR
│   └── FindRulesPnartraditional.m # Rule extraction for traditional PNAR
│
├── Datasets
│   ├── Dataset.xlsx / Dataset.mat   # Primary dataset (20x10 binary matrix)
│   └── Dataset1.xlsx / Dataset1.mat # Alternative dataset
│
├── Output Files
│   ├── AprioriRules.txt           # Generated Apriori rules
│   ├── PnarRules.txt              # Generated PNAR rules
│   ├── FirstPnar.txt              # Traditional PNAR output
│   └── FrequentItemsets.txt       # Discovered frequent itemsets
│
└── Documentation
    ├── README.md                  # This file
    ├── READ ME.txt                # Quick start guide
    └── Project Report.doc         # Full research documentation
```

## Quick Start

### Prerequisites

- MATLAB (base installation, no additional toolboxes required)

### Running the Algorithms

Open MATLAB, navigate to the project directory, and run:

```matlab
% Traditional Apriori Algorithm (positive rules only)
>> Apriori

% Traditional PNAR Algorithm (positive and negative rules)
>> Pnar

% Improved PNAR Algorithm (with correlation threshold)
>> Pnar_improved

% Alternative versions using Dataset1
>> Pnar1
>> Pnar_improved1
```

### Output

Results are written to text files in the project directory:
- `AprioriRules.txt` - Rules from Apriori algorithm
- `PnarRules.txt` - Rules from improved PNAR
- `FirstPnar.txt` - Rules from traditional PNAR

## Algorithm Parameters

### Apriori
| Parameter | Default | Description |
|-----------|---------|-------------|
| `minSup` | 0.2 | Minimum support threshold (20%) |
| `minConf` | 0.7 | Minimum confidence threshold (70%) |

### Traditional PNAR
| Parameter | Default | Description |
|-----------|---------|-------------|
| `minSup` | 0.2 | Minimum support threshold |
| `dms` | 0.40-0.50 | Dual measure support |
| `mc` | 0.70 | Main confidence |
| `dmc` | 0.15 | Dual confidence (for negative rules) |

### Improved PNAR
| Parameter | Default | Description |
|-----------|---------|-------------|
| `minSup` | 0.2 | Minimum support threshold |
| `dms` | 0.50 | Dual measure support |
| `P_mc` | 0.70 | Positive rule confidence |
| `N_mc` | 0.30 | Negative rule confidence (1 - P_mc) |
| `mincorr` | 0.1 | Minimum correlation threshold |

## Dataset Format

The algorithms expect a binary transaction matrix where:
- Rows represent transactions
- Columns represent items
- `1` indicates item presence, `0` indicates absence

Example (5 transactions, 4 items):
```
1 0 1 1
0 1 1 0
1 1 1 1
1 0 0 1
0 1 1 0
```

### Network Analysis

The algorithms can also be used for network link prediction by representing an undirected graph as an adjacency matrix. Association rules then suggest potential missing links in the network.

## Sample Output

```
Frequent Itemsets:
{Item 1} - Support: 60%
{Item 3} - Support: 80%
{Item 1, Item 3} - Support: 40%

Positive Association Rules:
Item 9 => Item 3 (Support: 40%, Confidence: 72.73%)
Item 1, Item 5 => Item 7 (Support: 25%, Confidence: 83.33%)

Negative Association Rules:
~Item 2 => ~Item 6 (Support: 35%, Confidence: 70%)
Item 4 => ~Item 8 (Support: 30%, Confidence: 75%)
```

## Key Features

- **Dual Confidence Approach**: Separate confidence thresholds for positive and negative rules
- **Correlation Threshold**: Filters rules based on statistical correlation for interestingness
- **Flexible Parameters**: Easily adjustable support, confidence, and correlation thresholds
- **Multiple Output Formats**: Results exported to readable text files

## References

For detailed methodology, mathematical foundations, and experimental results, refer to the included `Project Report.doc` (40 pages).

## License

This project was developed for academic/research purposes.
