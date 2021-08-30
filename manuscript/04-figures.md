---
title: "Chapter of course"
output: html_document
---

# Figures




## Make a plot

This is the same code as in chapter 2, but here we can show how setting `knitr` chunks helps us tidy stuff up.


```r
library(here)
```

```
## here() starts at /home/rstudio/Desktop/GitRepos/ITCR_Course_Template_Leanpub
```

```r
library(ggplot2)
library(magrittr)
```



```r
iris %>%
  ggplot(aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() +
  theme_bw()
```

{width: "672", align: "middle"}
![](resources/images/04-figures_files/figure-html/unnamed-chunk-3-1.png).
