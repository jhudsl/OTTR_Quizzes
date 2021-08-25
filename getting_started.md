# Getting Started with this Leanpub course template repository

This template repository includes all of the files that you need to get converting your Bookdown course that was set up from a [DaSL_Course_Template_Bookdown](https://github.com/jhudsl/DaSL_Course_Template_Bookdown/blob/main/getting_started.md) to a [Leanpub](https://leanpub.com/) course with quizzes.
If you haven't created a _Bookdown repository from this template, you should go to that [template repository's getting started section](https://github.com/jhudsl/DaSL_Course_Template_Bookdown/blob/main/getting_started.md) and start there.

<img src="https://docs.google.com/presentation/d/18k_QN7l6zqZQXoiRfKWzcYFXNXJJEo6j4daYGoc3UcU/export/png?id=18k_QN7l6zqZQXoiRfKWzcYFXNXJJEo6j4daYGoc3UcU&pageid=geb00d6af62_0_0" width="500" height="500"/>

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Setting up your Leanpub Github repository](#setting-up-your-leanpub-github-repository)
- [Linking to your _Bookdown Github repository](#linking-to-your-_bookdown-github-repository)
  - [Setting up quizzes](#setting-up-quizzes)
- [Leanpub rendering](#leanpub-rendering)
  - [Hosting your course on Leanpub](#hosting-your-course-on-leanpub)
  - [Setting up this repository checklist:](#setting-up-this-repository-checklist)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Setting up your Leanpub Github repository

In the upper right of this screen, click `Use this template` and follow the steps to set up your course's GitHub repository.

Name your repository fill in a short description (If this is an ITCR course, start the repo name with `ITCR_`).

##### Set up branches

*These settings are the same as we used in the Bookdown repository so we will need to set them up in the same way.

Go to `Settings` > `Branches` and click `Add rule`.
For `Branch name pattern`, put `main`.

_Protect the main branch_:  
Then check the box that says `Require pull request reviews before merging`.

_Make sure branches are updated_:  
- Check the box that says `Require status checks to pass before merging`.
- Underneath this also check the box that says `Require branches to be up to date before merging`.

_Use automatic spell and URL checks_:  
After the first pull request, a couple of checks will automatically happen and then appear here in settings.
Then, you can require these checks to pass before merging pull requests by returning here and selecting them - they are `url_check` and `style-n-check` they will check that the urls work and that the code is styled using the `stylr` package and that the spelling is correct using the spelling package respectively.
See the [Github Actions section in the Bookdown repository](#github-actions) for more details on these.

After setting up these new branch items, click `Create` and `Save changes`.

## Linking to your _Bookdown Github repository

In order to link your _Leanpub and _Bookdown repositories (so you only have to edit material in one place), you will need to do a little set up with a Github action in your course's _Bookdown repository.

In your _Bookdown repository, navigate to your github actions files, located in the `.gihub/workflows/` folder and open your `transfer-rendered-files.yml` file to edit.

It will look like [this](https://github.com/jhudsl/DaSL_Course_Template_Bookdown/blob/main/.github/workflows/transfer-rendered-files.yml)

In this file, you will see:
```
jobs:
  file-bookdown-pr:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code from Leanpub repo
        uses: actions/checkout@v2
        with:
          repository: jhudsl/DaSL_Course_Template_Leanpub
```

Change the `repository:` line to have the name of this new Leanpub repository.
Note if you haven't set a [GIT_TOKEN git secret](https://github.com/jhudsl/DaSL_Course_Template_Bookdown/blob/main/getting_started.md#set-up-github-secrets), you will need to do that by following the instructions linked in the _Bookdown repository's getting_started.md.

Optionally/Recommended -- if you would like to have PRs filed _automatically_ when you make changes to your _Bookdown repository, you will need to uncomment this section at the top of the file:
```
  workflow_dispatch:
  # Only run after the render finishes running
  # workflow_run:
  #  workflows: [ "Build, Render, and Push" ]
  #  branches: [ main ]
  #  types:
  #    - completed
```
If you choose not to have this run automatically you will need to [manually trigger this workflow](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) when you want your files to be copied from the Bookdown repository to the Leanpub repository.

After you merge these changes in the `main` branch you will be able to easily copy over the Leanpub-needed files from your Bookdown repository as you make content updates/changes/adds.

_Note that any content changes to non-quiz material needs to be done your course's Bookdown repository!
Do NOT change them here, in your Leanpub repository, otherwise your Bookdown course will not be updated._

### Setting up quizzes

See and copy this [template quiz](https://github.com/jhudsl/DaSL_Course_Template_Leanpub/blob/main/quizzes/quiz_ch1.md) to get started.
All quizzes need to be written in the Markua format. Refer to their [documentation](https://leanpub.com/markua/read#leanpub-auto-quizzes-and-exercises) (but note that it is sometimes vague or out of date).
The example question types in the template are ones that are verified to work.

After you add each new quiz to the `quizzes/` directory, it's filename needs to be added in its respective spot in the `Book.txt` file; this ensures its incorporated by Leanpub in the correct order.

You need to modify the `Book.txt` file in the `manuscript` directory to include the `.md` files that you wish in the order that you would like. We have also included a quiz example.
If you wanted two quizzes (one called `quiz_1.md` and one called `quiz_2.md`) you could duplicate and modify `quiz_1.md` for your needs and then you could make the `Book.txt` file look like this (assuming you created a chapter called `"03-chapter_of_course.Rmd"` and you wanted quiz_1 to be after `02-chapter-of_course` and quiz_2 to be after `03_chapter_of_course`:  

```
01-intro.md  
02-chapter_of_course.md  
quiz_1.md  
03-chapter_of_course.md  
quiz_2.md  
about.md  
```
Note that any `.md` files with an `#` in front of the name in the `Book.txt` file will be ignored by Leanpub. We have included an example of this in the `Book.txt` file.  

## Leanpub rendering

For convenience purposes the leanbuild package can do most of the formatting of links and etc for you (so long as you followed the formatting prescribed by the [getting_started.md document in the Bookdown Course Template repository](https://github.com/jhudsl/DaSL_Course_Template_Bookdown/blob/main/getting_started.md#setting-up-images-and-graphics).

Github actions in this repository will attempt to do the bookdown to leanpub conversions for you by running `leanbuild::bookdown_to_leanpub()` function at the top of the repository.
You can also run this command manually if you wish.

If you encounter issues with the leanbuild package, please file an issue on its [Github repository](https://github.com/jhudsl/leanbuild/issues).

### Hosting your course on Leanpub  

To host your course on Leanpub follow these steps:  

1) Make a Leanpub account here: https://leanpub.com/ if you don't already have one.   

2) Start a course  
 - Click on the 3 line menu button  
 - Click the author tab on the far left
 - Click Courses
 - Click the text that says `create a new course`
 - Fill out all the necessary information
 - Select using Git and GitHub (if you work with us at JHU there is a different protocol and additional settings you need to set which you should follow - [see this document](https://docs.google.com/document/d/18UQicXwf8d25ayKGF2BrinvRgB_R2ToVn5EDOUcxyoc/edit?usp=sharing) )
 - press the `add to plan` button

 3) Preview a new version
 - Click on the 3 line menu button
 - Click the author tab on the far left
 - Click Courses
 - Click on your course name/icon
 - Click "Preview New Version"
 - Click `Create Preview` button

 4) Once you are ready and you like your course, you can click the "Publish New Version" instead of "Preview New Version".

### Setting up this repository checklist:

 - [ ] `main` branch has been set up:
   - [ ] `Require pull request reviews before merging` box is checked.
   - [ ] `Require status checks to pass before merging` box is checked.
     - [ ] Underneath that `Require branches to be up to date before merging` box is checked.

 - [ ] [This course's _Bookdown repository has been linked in the github actions](./getting_started.md#linking-to-your-_bookdown-github-repository)

 - [ ] [This course's Leanpub has been set up](./getting_started.md#hosting-your-course-on-leanpub)