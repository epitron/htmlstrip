# htmlstrip

```
$ htmlstrip --help

Usage: htmlstrip [options] <file(s).html(.gz|.bz2|.xz)...>

Purpose:
  Strips extraneous tags from an HTML document, leaving only the bare minimum tags
  necessary to read the document.

  (Keep tags: ["a", "img", "div", "span", "p", "b", "i", "em", "strong", 
               "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "title",
               "ul", "li", "ol", "dl", "dd", "dt",
               "audio", "video", "source"])

Options:
   -i      Don't strip tags, just reindent the HTML
   -s      Scrub input of broken UTF-8 codes
   -d      Debug mode (show parser events)
```