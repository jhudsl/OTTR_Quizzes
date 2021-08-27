# This script is for running tests on leanbuild changes using a real repo
# It is called by https://github.com/jhudsl/leanbuild/tree/master/.github/workflows/render-leanpub.yml in the leanbuild repo

# Load latest build
devtools::load_all(here::here('leanbuild'))

# Run the thing 
leanbuild::bookdown_to_leanpub(
  footer_text = '*Please provide any feedback with [this form!](https://forms.gle/hc8Xt3Y2Znjb6M4Y7) We appreciate your thoughts.*'
  )