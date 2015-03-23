Introduction
============

The purpose of this document is to initiate the process that will lead
to the create of an Natural Language Processing (NLP) tool that predicts
the next word in a sentence being typed. Most smartphones come with such
functionality. In fact [Swiftkey](http://swiftkey.com/en/) a company
that produces one such keyboard for smartphones is involved in this
project.

The Data
========

Data for this project was sourced from a corpus called [HC
Corpora](www.corpora.heliohost.org). Only the english language corpus
was processed. The enlish language corpus consisted of three text
files: \* Blogs posts \* News articles \* Twitter messages

The data had to be cleaned of offensive and profane words. An balance
had to be reached to ensure that words that have a dual meaning (eg
balls or penis) are not removed. I took a decision in favour of
retaining words that have dual meanings, removing only clearly offensive
words.

Loading Data
------------

The following is some basic information about the raw text files that
will be processed: \* File size of Blogs file 200.4242077Mb. \* File
size of News file 196.2775126Mb. \* File size of Twitter file
159.364069Mb.

The data was originally downloaded on the `Fri Mar 13 09:45:13 2015`.

In order to reduce processing time the source file loading and profanity
cleanup is done once and the intermediate files are loaded automatically
the second time round. Once needs to remove the file
data/dsscapstone-003-001.RData so that the process is run from the
begining.

Information about the data that will be used (profanity words removed):

<table>
<thead>
<tr class="header">
<th align="left">Text Source</th>
<th align="left">Lines</th>
<th align="left">Words</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Blogs</td>
<td align="left">899288</td>
<td align="left">3.914266810^{7}</td>
</tr>
<tr class="even">
<td align="left">News</td>
<td align="left">1010242</td>
<td align="left">3.674980310^{7}</td>
</tr>
<tr class="odd">
<td align="left">Twitter</td>
<td align="left">2360148</td>
<td align="left">3.286870210^{7}</td>
</tr>
</tbody>
</table>
