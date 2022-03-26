### File naming convention

#### Goals

    - Facilitate easy and meaningful sorting by filename in a file system browser. 
    - Encode enough information to understand the nature of the image by scanning filenames. 
    - Have a structured, predictable format for the filename that is machine readable to automatically populate initial metadata to facilitate publishing.
    - Make the naming convention easy to understand and easily added/edited. 

The convention is:

    `seq_copyNum_pageNum_documentPart_pageArea_flags_dates.ext`

Where underscores (_) are field separators, and where applicable (flags and dates), multiple values for a field are separated by a dash (-).

Examples:
    
    `12.jpg`
    `12_5_pg_0_0.jpg`
    '12_5_pg_q1_t-l-c_18861023-18851024.jpg`

All but the first variable `seq` are optional. The fields become more specific as you go along, and so in many cases, unneeded fields can simply be left off. Code using this convention should know to expect a variable number of fields. You can also use a default value of `0` in cases where you need to quickly skip over fields for a collection. 

A thorough review of the material should be done ahead of time to determine which fields are needed for the project at hand. 

`seq` is an integer, starting at 1, that is essentially a page numbering system that could begin with the front cover and end with the back cover. This is the primary organizing and sorting mechanism for recreating the book in digital format. This is the only part of the base filename specification above that is not optional.

`copyNum` is an integer indicating a distinct image that would nonetheless duplicate another's filename. For example, two different images of the same complete page showing all edges, etc.

`pageNum` a string that records any actual page number printed on the page. This could maybe include roman numerals without causing too many problems. If there is no such page number, 0 can indicate this and keep our fields fixed. 

`documentPart`
    pg: simple page, the most commonly used value
    aa: front cover
    ab: inside front cover
    zy: inside back cover
    zz: back cover

    Probably not relevant for my purposes here, but eventually, could get more fine-grained, such as:

    tp: title page
    tc: table of contents
    dc: dedication
    etc.
 
`pageArea` can include the following descriptors:
    cc: the image captures all the content of the page, the most commonly used value
    q#: the primary quadrant the image falls in, where # is a value 1-4;

    Quadrants map to the page as you would expect:

    ---------
    | 1 | 2 |
    ---------
    | 3 | 4 |
    ---------

    If an image falls equally in multiple quadrants, the first applicable quandrant (uppermost, leftmost) should be specified.

    This is used to help orient people to where closeups are taken from.
    
`flags` describe certain visual aspects of the image artifact and can include any of the following:
    p: is photograph
    s: is scanned
    n: no edges visible
    t: top edge visible
    b: bottom edge visible
    l: left edge visible
    r: right edge visible
    f: visible fold, crease
    w: is two page spread
    c: is closeup

`dates` can be a multivalued set of dates in dash separated strings in the format YYYYMMDD. Examples of possible common situations include:
    1. A single date value, say, for a diary entry.
    2. Two dates: a start and end date, might make sense.
    3. An arbitrary number of dates, possibly capped at a small number for practical reasons.

`ext` is the relevant image filename extension, if applicable.

Code that uses this could provide a template based on the complete 
