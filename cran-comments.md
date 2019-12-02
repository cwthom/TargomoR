## Resubmission - TargomoR 0.2.0

In this version I have modified:

DESCRIPTION
- removed the unnecessary 'An R' start to the title
- put all software and package names in 'single quotes' in the description
- added a link to the API in <angle brackets>
- removed unnecessary capitalisation

R/man/NAMESPACE
- exported S3 print method for class 'tgm_capabilities'
- made arguments consistent for this method

## Resubmission - TargomoR 0.2.0

In this version I have fixed the NOTEs by:

- removing the `\url` tag from man/options.Rd
- fixing the broken CODE_OF_CONDUCT.md URI to a published webpage

# TargomoR 0.2.0

This is the first release to CRAN of the package.

## Test environments
* local Windows 10 install, R 3.6.1, R 3.5.3
* ubuntu 16.04 (on travis-ci), R oldrel, release, devel
* win-builder (oldrel, release, devel)
* R-hub

## R CMD check results

0 errors | 0 warnings | 2 notes

There were no ERRORs or WARNINGs. There are 2 NOTEs:

* This is a new release.
* Win-builder raises a NOTE about a URL in the documentation - this URL is correct.
