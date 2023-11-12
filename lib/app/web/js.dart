import 'dart:convert' as convert;

class JS {
  static String createRootDocument({
    List links = const [],
    List annotations = const [],
    int sectionCount = 1,
  }) {
    final jsLinks = convert.jsonEncode(links);
    final jsAnnotations = convert.jsonEncode(annotations);

    return """

    class RootDocument {
      constructor(links, annotations) {
        this.getInfo();
        this.setLinks(links);
        this.setAnnotations(annotations);
        this.getSections();
      }

      getInfo() {
        this.title = document.title;
        this.href = window.location.href;
        window.flutter_inappwebview.callHandler("onDocumentInfo", this.title, this.href);
      }

      setLinks(links) {
        this.links = links;
        links.forEach(l => { this.addLink(l); });
      }
      
      addLink(link) {
        
        let selector = 'a[href="'+link.href+'"]';
        let linkElement = document.querySelector(selector);
        if (linkElement != null) {
          linkElement.style.backgroundColor = link.color;
          linkElement.style.color = 'white';
          link['element'] = linkElement;
          this.links[link.id] = link;  
        } else {
            console.log('could not find link: '+link.href);
        }
      }
      
      updateLink(link) {
        this.links[link.id].element.style.backgroundColor = link.color;
      }

      getSections() {
        this.sections = [{
          'tag': 'h1',
          'sections': [],
        }];
        this.sectionIndex = 0;

        let root = document.querySelector('article');
        if (root == null) {
          root = document.querySelector('main');
        }
        if (root == null) { return; }

        this.getContent(root);
        
        
        window.flutter_inappwebview.callHandler("onDocumentContent", 
          this.sections.map(s => { 
            return {
              'tag': s.tag,
              'text': s.text,
              'parent': s.parent,
              'sections': s.sections
            }; 
          })
        );
      }

      getContent(element) {

        if (element.innerText == null || element.innerText == '') return;

        let currentSection = this.sections[this.sectionIndex];
        let tagName = element.tagName.toLowerCase();
        let isText = ['p','span','ul','ol','blockquote'].includes(tagName);
        if (isText) {
          // add text to section
          this.sections.push({
            'tag': tagName ,
            'text': element.innerText,
            'parent': this.sectionIndex,
            'element': element,
          });
          currentSection['sections'].push(this.sections.length - 1);
          return;
        }

        let isTitle = ['h1','h2','h3','h4'].includes(tagName);
        if (isTitle) {
          let isDocumentTitle = currentSection['title'] == null && tagName == 'h1';
          if (isDocumentTitle) {
            currentSection['title'] = element.innerText;
            currentSection['tag'] = tagName;
            return;
          }

          let currentLevel = parseInt(tagName[1]);
          let parentLevel = parseInt(currentSection['tag'][1]);

          let isSameLevel = currentLevel == parentLevel;
          let isLowerLevel = currentLevel > parentLevel;
          let isUpperLevel = currentLevel < parentLevel;
          if (isSameLevel) {
            if (currentSection['parent'] != null) {
              this.sectionIndex = currentSection['parent'];
              currentSection = this.sections[this.sectionIndex];
            }
            this.sections.push({
              'tag': tagName,
              'text': element.innerText,
              'sections': [],
              'parent': this.sectionIndex,
              'element': element,
            });
            this.sectionIndex = this.sections.length - 1;
            currentSection['sections'].push(this.sectionIndex);
          } else if (isLowerLevel) {

            this.sections.push({
              'tag': tagName,
              'text': element.innerText,
              'sections': [],
              'parent': this.sectionIndex,
              'element': element,
            });
            this.sectionIndex = this.sections.length - 1;
            currentSection['sections'].push(this.sectionIndex);

          } else if (isUpperLevel) {


            while (true) {
                this.sectionIndex = this.sections[this.sectionIndex]['parent'];
                let notAtRoot = this.sections[this.sectionIndex]['parent'] != null;
                let notAtSibling = this.sections[this.sectionIndex]['tag'] != tagName;
                let shouldNotContinue = !(notAtRoot && notAtSibling);
                if(shouldNotContinue) { break; }
            }
            if (this.sections[this.sectionIndex]['parent'] != null) {
              this.sectionIndex = this.sections[this.sectionIndex]['parent'];
            }
            currentSection = this.sections[this.sectionIndex];

            this.sections.push({
              'tag': tagName,
              'text': element.innerText,
              'sections': [],
              'parent': this.sectionIndex,
              'element': element,
            });
            this.sectionIndex = this.sections.length - 1;
            currentSection['sections'].push(this.sectionIndex);
          }
          return;
        }

        for (let i = 0; i < element.children.length; i++) {
          this.getContent(element.children[i]);
        }
      }

      scrollToSection(sectionIndex) {
        this.sections[sectionIndex]['element'].scrollIntoView();
      }

      async setAnnotations(annotations) {
        this.loadingAnnotations = true;
        this.annotations = {};
        Promise.all(annotations.map(async a => { 
          await this.addAnnotation(a); 
        })).then((values) => { this.loadingAnnotations = false; });
        //this.loadingAnnotations = false;
      }

      async addAnnotation(annotation) {
        let _anchor = await anchor(document.body, annotation.target.selector);
        let _highlights = highlightRange(_anchor);
        _highlights.forEach(h => {
          h.style.backgroundColor = annotation.color;
          h.addEventListener('click', event => {
            window.flutter_inappwebview.callHandler("onHighlightClicked", annotation.id);
          });
        });
        let notify = !this.annotations.hasOwnProperty(annotation.id) && !this.loadingAnnotations;
        
        this.annotations[annotation.id] = {
          'target': annotation.target,
          'anchor': _anchor,
          'highlights': _highlights
        };
        
        if (notify) window.flutter_inappwebview.callHandler("onHighlightClicked", annotation.id);
      }
      
      updateAnnotation(annotationData) {
        removeHighlights(this.annotations[annotationData.id].highlights);
        this.addAnnotation(annotationData);
      }
    }

    var rootDoc = new RootDocument($jsLinks, $jsAnnotations, $sectionCount);

  """;
  }

  static String updateSavedLink(Map<String, dynamic> link) => """
    rootDoc.updateLink(${convert.jsonEncode(link)});
  """;
  static String addSavedLink(Map<String, dynamic> link) => """
    rootDoc.addLink(${convert.jsonEncode(link)});
  """;

  static String updateAnnotation(Map<String, dynamic> annotation) => """
    rootDoc.updateAnnotation(${convert.jsonEncode(annotation)});
  """;

  static String addAnnotation(Map<String, dynamic> annotation) {
    /*
      annotation
      - id
      - color
      - target
     */
    return """
    //console.log(${convert.jsonEncode(annotation)});
    rootDoc.addAnnotation(${convert.jsonEncode(annotation)});
    """;
  }

  static String touchEndListener = """ 
  console.log('injected');
  // Listens for swipe of hyperlink to add link to tree
    // Emits: onLinkSelected
    // Returns:
      // String text
      // String href
      
  // Listens for text selection to add tag, highlight, or field value
    // Emits: onTextSelection
    // Returns:
      // String textSelection
  
  var lastTouchedLink;
  var lastTouchId;
  var lastTouchMinX = 1000;
  var lastTouchMaxX = 0; 
  
  document.addEventListener('touchmove', function(e) {
      e = e || window.event;
      var target = e.target || e.srcElement;
      var href = target.getAttribute('href');
      if (href == null) { return; }
      var touch = e.touches[0];
      if (touch.identifier != lastTouchId) {
        lastTouchId = touch.identifier;
        lastTouchMinX = 1000;
        lastTouchMaxX = 0; 
      } else {
        if (lastTouchMinX > touch.screenX) {
          lastTouchMinX = touch.screenX;
        }
        if (lastTouchMaxX < touch.screenX) {
          lastTouchMaxX = touch.screenX
        }
      }
  }, false);

  var lastTextSelection;
  var lastTextSelectionElement;
  
  document.addEventListener('touchend', function(e) {
    e = e || window.event;
    let target = e.target || e.srcElement;
    
    let href = target.getAttribute('href');
    let text = target.innerText;
    if (href != null) {
      let swipeSize = lastTouchMaxX - lastTouchMinX;
      if (swipeSize > 100) {
        if (href.startsWith('/')) {
          href = 'https://' + window.location.hostname + href;
        }
        if (lastTouchedLink != href) {
          console.log('link to save: ' + href);
          window.flutter_inappwebview.callHandler("onLinkSelected", text, href);
          
        }
      }
    } else {
      let textSelection = window.getSelection().toString();
      if (textSelection != lastTextSelection && textSelection != '') {
        lastTextSelection = textSelection;
        lastTextSelectionElement = target;
        //console.log('text selection: ' + textSelection);
        window.flutter_inappwebview.callHandler("onTextSelection", textSelection);
      }
    }
  
  }, false);
  """;

  static String annotationFunctions = r"""

  function getAnnotationTarget() {
    const selection = window.getSelection();
    if (selection == null) { return; }
    const range = selection.getRangeAt(0);
    const root = document.body;
    
    const target = {
      source: window.location.href,

      // In the Hypothesis API the field containing the selectors is called
      // `selector`, despite being a list.
      selector: describe(root, range),
    };
   
    window.flutter_inappwebview.callHandler("onAnnotationTarget", target);
  }
 
  
  """;

  static String checkForList = r"""
  var unorderedLists = document.querySelectorAll('ul');
  for (var i = 0; i < unorderedLists.length; i++) {
    var listSize = unorderedLists[i].querySelectorAll('li').length;
    if (listSize >= 20) {
      window.flutter_inappwebview.callHandler("foundList");
      break;
    }
  }
  """;

  static String createAnnotation = r"""
    createAnnotation();
  """;

  static String getAnnotationTarget = """
    getAnnotationTarget();
  """;

  static String scrollListener = """
  // Listens for user to stop scrolling
    // Emits: onScrollEnd
    // Returns:
      // int scrollPosition
  var timer = null;
  document.addEventListener('scroll', function(e) {
    if(timer !== null) {
        clearTimeout(timer);        
    }
    timer = setTimeout(function() {
      // Once scrolling has stopped
      window.flutter_inappwebview.callHandler("onScrollEnd", window.scrollY);
    }, 150);
  });
  """;

  static String imageSelectionListener = """

      var lastImageClick;

      document.addEventListener('touchstart', (e) => {
          if (e.target.tagName != 'IMG') return;

          lastImageClick = Date.now();
      });

      document.addEventListener('touchend', (e) => {
          if (e.target.tagName != 'IMG' || !lastImageClick) return;
          const now = Date.now();
          if (now - lastImageClick > 2000 && now - lastImageClick < 10000) {
              lastImageClick = null;
              window.flutter_inappwebview.callHandler("imageSelected", e.target.src);
          }
      });

      function getImageUrl() {
          // Todo: handle youtube videos

          let imageUrl;

          const uri = new URL(location.href);

          if (uri.hostname == 'www.amazon.com') {


              const imageContainer = document.querySelector('#main-image-container');
              let images = Array.from(imageContainer.querySelectorAll('img'));

              images.sort((a, b) => b.height - a.height);
              imageUrl = images[0].src;

          } else if (uri.hostname == 'youtube.com') {
              // do nothing

          } else if (uri.hostname.includes('wikipedia.org')) {
              const imageContainer = document.querySelector('.infobox-image');
              imageUrl = imageContainer.querySelector('img')?.src;

          } else {
              let images = Array.from(document.querySelectorAll('img'));

              // const title = document.title.toLocaleLowerCase();
              // images = images.map((img) => {
              //     return {
              //         relevance: img.alt?.toLocaleLowerCase().split(' ').filter((word) => title.includes(word)).length,
              //         height: img.height,
              //         src: img.src
              //     }
              // })
              images.sort((a, b) => {
                  const comp = b.relevance - a.relevance;
                  if (comp == 0) return b.height - a.height;
                  else return comp;

              });

              imageUrl = images[0].src;
          }



          return imageUrl;
      }

  """;

  static String clickListener = """
    // Listens for user click of hyperlink
      // Emits: onLinkClicked
      // Returns:
        // String href
        // String text
        
    function getLinkElement(element) {
       let parent = element; 
       while(true) {
         if (parent.tagName == 'A') { return parent; }
         if (parent == document.body) { return;}
         parent = parent.parentElement;
       }
    }

    function removeLastClickedElement() {
      console.log('removing element');
      console.log(lastClickedElement.toString());
      lastClickedElement?.remove();
    }
    
    var lastClickedElement;
    let clickedLink;
    let waitingOnDoubleClick = false;
    let doubleClickedLink;
    let isDelayedClick = false;
    let clickTarget;
    document.addEventListener('click', function (event) {
       let target = event.target || event.srcElement;
       lastClickedElement = target;
       console.log('clicked body');
       let targetIsHighlight = target.tagName != 'HYPOTHESIS-HIGHLIGHT';
       if (!targetIsHighlight) { return; }
       let linkElement = getLinkElement(target);
       
       if (linkElement == null) { 
        window.flutter_inappwebview.callHandler("onDocumentBodyClicked");
       } else {
        window.flutter_inappwebview.callHandler("onLinkClicked", linkElement.innerText, linkElement.href);
       }
       
        
      //  if (clickedLink == target && !isDelayedClick) { doubleClickedLink = target; }
      //  if (isDelayedClick) { isDelayedClick = false; }
       
      //  let delayClick = doubleClickedLink != target && !waitingOnDoubleClick;
      //  let saveLink = doubleClickedLink == target && waitingOnDoubleClick;
      //  let preventClick = doubleClickedLink == target && !waitingOnDoubleClick;

       
      //  if (delayClick) {
         
      //   event.stopPropagation();
      //   event.preventDefault();
      //   clickedLink = target;
      //   waitingOnDoubleClick = true;
      //   setTimeout(function(){ isDelayedClick = true; target.click(); }, 1000);
      //   return false;
       
           
      //  } else if (saveLink)  {
      //    event.stopPropagation();
      //    event.preventDefault();
      //    waitingOnDoubleClick = false;
      //    if (linkElement != null) {
      //        window.flutter_inappwebview.callHandler("onLinkSelected", linkElement.innerText, linkElement.href);
      //    }
      //    return false;
    
      //  } else { 
      //   clickedLink = null;
      //   doubleClickedLink = null;
      //   waitingOnDoubleClick = false;
      //   if (preventClick) {
      //     event.stopPropagation();
      //     event.preventDefault();
      //     return false;
      //   } 
      //  }
    });
   
    
    
    
  """;


  static String inputListener = """
    document.addEventListener('keydown', (e) => {
      const key = e.code?.replace('Key', '');
      if (key.includes('Enter')) {
          const inputText = e.target.value;
          window.flutter_inappwebview.callHandler("onInputEntered", inputText);
      }
    });
  """;

  static String focusListener = """
  
  """;

  static String clearSelectedText = """
    if (window.getSelection) {
      if (window.getSelection().empty) {  // Chrome
        window.getSelection().empty();
      } else if (window.getSelection().removeAllRanges) {  // Firefox
        window.getSelection().removeAllRanges();
      }
    } else if (document.selection) {  // IE?
      document.selection.empty();
    }
  """;

  static String scrollToSection(int sectionIndex) {
    return """
    rootDoc.scrollToSection($sectionIndex);
    """;
  }

  static String updateGoogleSearch(String searchText) {
    return """
    
    let header = document.querySelector('header');
    let input = header.querySelector('input');
    input.value = $searchText;
    let event = document.createEvent('Events');
    event.initEvent('touchstart', true, true);
    input.dispatchEvent(event);
    
    let results = [];
    header.querySelectorAll('li').forEach(e => { results.push(e.innerText); });
    window.flutter_inappwebview.callHandler("onSearchResults", results);
    """;
  }

  static String hypothesisHelpers = r"""
  
  /**
   * @typedef {import('../../types/api').Selector} Selector
   */
  
  /**
   * @param {RangeAnchor|TextPositionAnchor|TextQuoteAnchor} anchor
   * @param {Object} [options]
   *  @param {number} [options.hint]
   */
  async function querySelector(anchor, options = {}) {
    return anchor.toRange(options);
  }
  
  /**
   * Anchor a set of selectors.
   *
   * This function converts a set of selectors into a document range.
   * It encapsulates the core anchoring algorithm, using the selectors alone or
   * in combination to establish the best anchor within the document.
   *
   * @param {Element} root - The root element of the anchoring context.
   * @param {Selector[]} selectors - The selectors to try.
   * @param {Object} [options]
   *   @param {number} [options.hint]
   */
  function anchor(root, selectors, options = {}) {
    let position = null;
    let quote = null;
    let range = null;
  
    // Collect all the selectors
    for (let selector of selectors) {
      switch (selector.type) {
        case 'TextPositionSelector':
          position = selector;
          options.hint = position.start; // TextQuoteAnchor hint
          break;
        case 'TextQuoteSelector':
          quote = selector;
          break;
        case 'RangeSelector':
          range = selector;
          break;
      }
    }
  
    /**
     * Assert the quote matches the stored quote, if applicable
     * @param {Range} range
     */
    const maybeAssertQuote = range => {
      if (quote?.exact && range.toString() !== quote.exact) {
        throw new Error('quote mismatch');
      } else {
        return range;
      }
    };
  
    // From a default of failure, we build up catch clauses to try selectors in
    // order, from simple to complex.
    /** @type {Promise<Range>} */
    let promise = Promise.reject('unable to anchor');
  
    if (range) {
      promise = promise.catch(() => {
        let anchor = RangeAnchor.fromSelector(root, range);
        return querySelector(anchor, options).then(maybeAssertQuote);
      });
    }
  
    if (position) {
      promise = promise.catch(() => {
        let anchor = TextPositionAnchor.fromSelector(root, position);
        return querySelector(anchor, options).then(maybeAssertQuote);
      });
    }
  
    if (quote) {
      promise = promise.catch(() => {
        let anchor = TextQuoteAnchor.fromSelector(root, quote);
        return querySelector(anchor, options);
      });
    }
  
    return promise;
  }
  
  /**
   * @param {Element} root
   * @param {Range} range
   */
  function describe(root, range) {
    const types = [RangeAnchor, TextPositionAnchor, TextQuoteAnchor];
    const result = [];
    for (let type of types) {
      try {
        const anchor = type.fromRange(root, range);
        result.push(anchor.toSelector());
      } catch (error) {
        continue;
      }
    }
    return result;
  }
    
    /********************************************
    * client/src/annotator/anchoring/types.js
    *********************************************/
    
    class RangeAnchor {
    /**
     * @param {Node} root - A root element from which to anchor.
     * @param {Range} range -  A range describing the anchor.
     */
    constructor(root, range) {
      this.root = root;
      this.range = range;
    }
  
    /**
     * @param {Node} root -  A root element from which to anchor.
     * @param {Range} range -  A range describing the anchor.
     */
    static fromRange(root, range) {
      return new RangeAnchor(root, range);
    }
  
    /**
     * Create an anchor from a serialized `RangeSelector` selector.
     *
     * @param {Element} root -  A root element from which to anchor.
     * @param {RangeSelector} selector
     */
    static fromSelector(root, selector) {
      const startContainer = nodeFromXPath(selector.startContainer, root);
      if (!startContainer) {
        throw new Error('Failed to resolve startContainer XPath');
      }
  
      const endContainer = nodeFromXPath(selector.endContainer, root);
      if (!endContainer) {
        throw new Error('Failed to resolve endContainer XPath');
      }
  
      const startPos = TextPosition.fromCharOffset(
        startContainer,
        selector.startOffset
      );
      const endPos = TextPosition.fromCharOffset(
        endContainer,
        selector.endOffset
      );
  
      const range = new TextRange(startPos, endPos).toRange();
      return new RangeAnchor(root, range);
    }
  
    toRange() {
      return this.range;
    }
  
    /**
     * @return {RangeSelector}
     */
    toSelector() {
      // "Shrink" the range so that it tightly wraps its text. This ensures more
      // predictable output for a given text selection.
      const normalizedRange = TextRange.fromRange(this.range).toRange();
  
      const textRange = TextRange.fromRange(normalizedRange);
      const startContainer = xpathFromNode(textRange.start.element, this.root);
      const endContainer = xpathFromNode(textRange.end.element, this.root);
  
      return {
        type: 'RangeSelector',
        startContainer,
        startOffset: textRange.start.offset,
        endContainer,
        endOffset: textRange.end.offset,
      };
    }
  }
  
  /**
   * Converts between `TextPositionSelector` selectors and `Range` objects.
   */
  class TextPositionAnchor {
    /**
     * @param {Element} root
     * @param {number} start
     * @param {number} end
     */
    constructor(root, start, end) {
      this.root = root;
      this.start = start;
      this.end = end;
    }
  
    /**
     * @param {Element} root
     * @param {Range} range
     */
    static fromRange(root, range) {
      const textRange = TextRange.fromRange(range).relativeTo(root);
      return new TextPositionAnchor(
        root,
        textRange.start.offset,
        textRange.end.offset
      );
    }
    /**
     * @param {Element} root
     * @param {TextPositionSelector} selector
     */
    static fromSelector(root, selector) {
      return new TextPositionAnchor(root, selector.start, selector.end);
    }
  
    /**
     * @return {TextPositionSelector}
     */
    toSelector() {
      return {
        type: 'TextPositionSelector',
        start: this.start,
        end: this.end,
      };
    }
  
    toRange() {
      return TextRange.fromOffsets(this.root, this.start, this.end).toRange();
    }
  }
  
  /**
   * @typedef QuoteMatchOptions
   * @prop {number} [hint] - Expected position of match in text. See `matchQuote`.
   */
  
  /**
   * Converts between `TextQuoteSelector` selectors and `Range` objects.
   */
  class TextQuoteAnchor {
    /**
     * @param {Element} root - A root element from which to anchor.
     * @param {string} exact
     * @param {Object} context
     *   @param {string} [context.prefix]
     *   @param {string} [context.suffix]
     */
    constructor(root, exact, context = {}) {
      this.root = root;
      this.exact = exact;
      this.context = context;
    }
  
    /**
     * Create a `TextQuoteAnchor` from a range.
     *
     * Will throw if `range` does not contain any text nodes.
     *
     * @param {Element} root
     * @param {Range} range
     */
    static fromRange(root, range) {
      const text = /** @type {string} */ (root.textContent);
      const textRange = TextRange.fromRange(range).relativeTo(root);
  
      const start = textRange.start.offset;
      const end = textRange.end.offset;
  
      // Number of characters around the quote to capture as context. We currently
      // always use a fixed amount, but it would be better if this code was aware
      // of logical boundaries in the document (paragraph, article etc.) to avoid
      // capturing text unrelated to the quote.
      //
      // In regular prose the ideal content would often be the surrounding sentence.
      // This is a natural unit of meaning which enables displaying quotes in
      // context even when the document is not available. We could use `Intl.Segmenter`
      // for this when available.
      const contextLen = 32;
  
      return new TextQuoteAnchor(root, text.slice(start, end), {
        prefix: text.slice(Math.max(0, start - contextLen), start),
        suffix: text.slice(end, Math.min(text.length, end + contextLen)),
      });
    }
  
    /**
     * @param {Element} root
     * @param {TextQuoteSelector} selector
     */
    static fromSelector(root, selector) {
      const { prefix, suffix } = selector;
      return new TextQuoteAnchor(root, selector.exact, { prefix, suffix });
    }
  
    /**
     * @return {TextQuoteSelector}
     */
    toSelector() {
      return {
        type: 'TextQuoteSelector',
        exact: this.exact,
        prefix: this.context.prefix,
        suffix: this.context.suffix,
      };
    }
  
    /**
     * @param {QuoteMatchOptions} [options]
     */
    toRange(options = {}) {
      return this.toPositionAnchor(options).toRange();
    }
  
    /**
     * @param {QuoteMatchOptions} [options]
     */
    toPositionAnchor(options = {}) {
      const text = /** @type {string} */ (this.root.textContent);
      const match = matchQuote(text, this.exact, {
        ...this.context,
        hint: options.hint,
      });
      if (!match) {
        throw new Error('Quote not found');
      }
      return new TextPositionAnchor(this.root, match.start, match.end);
    }
  }
  
  /********************************************************
  ***** client/src/annotator/anchoring/text-range.js ******
  ********************************************************/
  
   /**
   * Return the combined length of text nodes contained in `node`.
   *
   * @param {Node} node
   */
  function nodeTextLength(node) {
    switch (node.nodeType) {
      case Node.ELEMENT_NODE:
      case Node.TEXT_NODE:
        // nb. `textContent` excludes text in comments and processing instructions
        // when called on a parent element, so we don't need to subtract that here.
  
        return /** @type {string} */ (node.textContent).length;
      default:
        return 0;
    }
  }
  
  /**
   * Return the total length of the text of all previous siblings of `node`.
   *
   * @param {Node} node
   */
  function previousSiblingsTextLength(node) {
    let sibling = node.previousSibling;
    let length = 0;
    while (sibling) {
      length += nodeTextLength(sibling);
      sibling = sibling.previousSibling;
    }
    return length;
  }
  
  /**
   * Resolve one or more character offsets within an element to (text node, position)
   * pairs.
   *
   * @param {Element} element
   * @param {number[]} offsets - Offsets, which must be sorted in ascending order
   * @return {{ node: Text, offset: number }[]}
   */
  function resolveOffsets(element, ...offsets) {
    let nextOffset = offsets.shift();
    const nodeIter = /** @type {Document} */ (
      element.ownerDocument
    ).createNodeIterator(element, NodeFilter.SHOW_TEXT);
    const results = [];
  
    let currentNode = nodeIter.nextNode();
    let textNode;
    let length = 0;
  
    // Find the text node containing the `nextOffset`th character from the start
    // of `element`.
    while (nextOffset !== undefined && currentNode) {
      textNode = /** @type {Text} */ (currentNode);
      if (length + textNode.data.length > nextOffset) {
        results.push({ node: textNode, offset: nextOffset - length });
        nextOffset = offsets.shift();
      } else {
        currentNode = nodeIter.nextNode();
        length += textNode.data.length;
      }
    }
  
    // Boundary case.
    while (nextOffset !== undefined && textNode && length === nextOffset) {
      results.push({ node: textNode, offset: textNode.data.length });
      nextOffset = offsets.shift();
    }
  
    if (nextOffset !== undefined) {
      throw new RangeError('Offset exceeds text length');
    }
  
    return results;
  }
  
  let RESOLVE_FORWARDS = 1;
  let RESOLVE_BACKWARDS = 2;
  
  /**
   * Represents an offset within the text content of an element.
   *
   * This position can be resolved to a specific descendant node in the current
   * DOM subtree of the element using the `resolve` method.
   */
  class TextPosition {
    /**
     * Construct a `TextPosition` that refers to the text position `offset` within
     * the text content of `element`.
     *
     * @param {Element} element
     * @param {number} offset
     */
    constructor(element, offset) {
      if (offset < 0) {
        throw new Error('Offset is invalid');
      }
  
      /** Element that `offset` is relative to. */
      this.element = element;
  
      /** Character offset from the start of the element's `textContent`. */
      this.offset = offset;
    }
  
    /**
     * Return a copy of this position with offset relative to a given ancestor
     * element.
     *
     * @param {Element} parent - Ancestor of `this.element`
     * @return {TextPosition}
     */
    relativeTo(parent) {
      if (!parent.contains(this.element)) {
        throw new Error('Parent is not an ancestor of current element');
      }
  
      let el = this.element;
      let offset = this.offset;
      while (el !== parent) {
        offset += previousSiblingsTextLength(el);
        el = /** @type {Element} */ (el.parentElement);
      }
  
      return new TextPosition(el, offset);
    }
  
    /**
     * Resolve the position to a specific text node and offset within that node.
     *
     * Throws if `this.offset` exceeds the length of the element's text. In the
     * case where the element has no text and `this.offset` is 0, the `direction`
     * option determines what happens.
     *
     * Offsets at the boundary between two nodes are resolved to the start of the
     * node that begins at the boundary.
     *
     * @param {Object} [options]
     *   @param {RESOLVE_FORWARDS|RESOLVE_BACKWARDS} [options.direction] -
     *     Specifies in which direction to search for the nearest text node if
     *     `this.offset` is `0` and `this.element` has no text. If not specified
     *     an error is thrown.
     * @return {{ node: Text, offset: number }}
     * @throws {RangeError}
     */
    resolve(options = {}) {
      try {
        return resolveOffsets(this.element, this.offset)[0];
      } catch (err) {
        if (this.offset === 0 && options.direction !== undefined) {
          const tw = document.createTreeWalker(
            this.element.getRootNode(),
            NodeFilter.SHOW_TEXT
          );
          tw.currentNode = this.element;
          const forwards = options.direction === RESOLVE_FORWARDS;
          const text = /** @type {Text|null} */ (
            forwards ? tw.nextNode() : tw.previousNode()
          );
          if (!text) {
            throw err;
          }
          return { node: text, offset: forwards ? 0 : text.data.length };
        } else {
          throw err;
        }
      }
    }
  
    /**
     * Construct a `TextPosition` that refers to the `offset`th character within
     * `node`.
     *
     * @param {Node} node
     * @param {number} offset
     * @return {TextPosition}
     */
    static fromCharOffset(node, offset) {
      switch (node.nodeType) {
        case Node.TEXT_NODE:
          return TextPosition.fromPoint(node, offset);
        case Node.ELEMENT_NODE:
          return new TextPosition(/** @type {Element} */ (node), offset);
        default:
          throw new Error('Node is not an element or text node');
      }
    }
  
    /**
     * Construct a `TextPosition` representing the range start or end point (node, offset).
     *
     * @param {Node} node - Text or Element node
     * @param {number} offset - Offset within the node.
     * @return {TextPosition}
     */
    static fromPoint(node, offset) {
      switch (node.nodeType) {
        case Node.TEXT_NODE: {
          if (offset < 0 || offset > /** @type {Text} */ (node).data.length) {
            throw new Error('Text node offset is out of range');
          }
  
          if (!node.parentElement) {
            throw new Error('Text node has no parent');
          }
  
          // Get the offset from the start of the parent element.
          const textOffset = previousSiblingsTextLength(node) + offset;
  
          return new TextPosition(node.parentElement, textOffset);
        }
        case Node.ELEMENT_NODE: {
          if (offset < 0 || offset > node.childNodes.length) {
            throw new Error('Child node offset is out of range');
          }
  
          // Get the text length before the `offset`th child of element.
          let textOffset = 0;
          for (let i = 0; i < offset; i++) {
            textOffset += nodeTextLength(node.childNodes[i]);
          }
  
          return new TextPosition(/** @type {Element} */ (node), textOffset);
        }
        default:
          throw new Error('Point is not in an element or text node');
      }
    }
  }
  
  /**
   * Represents a region of a document as a (start, end) pair of `TextPosition` points.
   *
   * Representing a range in this way allows for changes in the DOM content of the
   * range which don't affect its text content, without affecting the text content
   * of the range itself.
   */
  class TextRange {
    /**
     * Construct an immutable `TextRange` from a `start` and `end` point.
     *
     * @param {TextPosition} start
     * @param {TextPosition} end
     */
    constructor(start, end) {
      this.start = start;
      this.end = end;
    }
  
    /**
     * Return a copy of this range with start and end positions relative to a
     * given ancestor. See `TextPosition.relativeTo`.
     *
     * @param {Element} element
     */
    relativeTo(element) {
      return new TextRange(
        this.start.relativeTo(element),
        this.end.relativeTo(element)
      );
    }
  
    /**
     * Resolve the `TextRange` to a DOM range.
     *
     * The resulting DOM Range will always start and end in a `Text` node.
     * Hence `TextRange.fromRange(range).toRange()` can be used to "shrink" a
     * range to the text it contains.
     *
     * May throw if the `start` or `end` positions cannot be resolved to a range.
     *
     * @return {Range}
     */
    toRange() {
      let start;
      let end;
  
      if (
        this.start.element === this.end.element &&
        this.start.offset <= this.end.offset
      ) {
        // Fast path for start and end points in same element.
        [start, end] = resolveOffsets(
          this.start.element,
          this.start.offset,
          this.end.offset
        );
      } else {
        start = this.start.resolve({ direction: RESOLVE_FORWARDS });
        end = this.end.resolve({ direction: RESOLVE_BACKWARDS });
      }
  
      const range = new Range();
      range.setStart(start.node, start.offset);
      range.setEnd(end.node, end.offset);
      return range;
    }
  
    /**
     * Convert an existing DOM `Range` to a `TextRange`
     *
     * @param {Range} range
     * @return {TextRange}
     */
    static fromRange(range) {
      const start = TextPosition.fromPoint(
        range.startContainer,
        range.startOffset
      );
      const end = TextPosition.fromPoint(range.endContainer, range.endOffset);
      return new TextRange(start, end);
    }
  
    /**
     * Return a `TextRange` from the `start`th to `end`th characters in `root`.
     *
     * @param {Element} root
     * @param {number} start
     * @param {number} end
     */
    static fromOffsets(root, start, end) {
      return new TextRange(
        new TextPosition(root, start),
        new TextPosition(root, end)
      );
    }
  }
  
  /********************************************************
  ******* client/src/annotator/anchoring/xpath.js  ********
  ********************************************************/
  
  /**
   * Get the node name for use in generating an xpath expression.
   *
   * @param {Node} node
   */
  function getNodeName(node) {
    const nodeName = node.nodeName.toLowerCase();
    let result = nodeName;
    if (nodeName === '#text') {
      result = 'text()';
    }
    return result;
  }
  
  /**
   * Get the index of the node as it appears in its parent's child list
   *
   * @param {Node} node
   */
  function getNodePosition(node) {
    let pos = 0;
    /** @type {Node|null} */
    let tmp = node;
    while (tmp) {
      if (tmp.nodeName === node.nodeName) {
        pos += 1;
      }
      tmp = tmp.previousSibling;
    }
    return pos;
  }
  
  function getPathSegment(node) {
    const name = getNodeName(node);
    const pos = getNodePosition(node);
    return `${name}[${pos}]`;
  }
  
  /**
   * A simple XPath generator which can generate XPaths of the form
   * /tag[index]/tag[index].
   *
   * @param {Node} node - The node to generate a path to
   * @param {Node} root - Root node to which the returned path is relative
   */
  function xpathFromNode(node, root) {
    let xpath = '';
  
    /** @type {Node|null} */
    let elem = node;
    while (elem !== root) {
      if (!elem) {
        throw new Error('Node is not a descendant of root');
      }
      xpath = getPathSegment(elem) + '/' + xpath;
      elem = elem.parentNode;
    }
    xpath = '/' + xpath;
    xpath = xpath.replace(/\/$/, ''); // Remove trailing slash
  
    return xpath;
  }
  
  /**
   * Return the `index`'th immediate child of `element` whose tag name is
   * `nodeName` (case insensitive).
   *
   * @param {Element} element
   * @param {string} nodeName
   * @param {number} index
   */
  function nthChildOfType(element, nodeName, index) {
    nodeName = nodeName.toUpperCase();
  
    let matchIndex = -1;
    for (let i = 0; i < element.children.length; i++) {
      const child = element.children[i];
      if (child.nodeName.toUpperCase() === nodeName) {
        ++matchIndex;
        if (matchIndex === index) {
          return child;
        }
      }
    }
  
    return null;
  }
  
  /**
   * Evaluate a _simple XPath_ relative to a `root` element and return the
   * matching element.
   *
   * A _simple XPath_ is a sequence of one or more `/tagName[index]` strings.
   *
   * Unlike `document.evaluate` this function:
   *
   *  - Only supports simple XPaths
   *  - Is not affected by the document's _type_ (HTML or XML/XHTML)
   *  - Ignores element namespaces when matching element names in the XPath against
   *    elements in the DOM tree
   *  - Is case insensitive for all elements, not just HTML elements
   *
   * The matching element is returned or `null` if no such element is found.
   * An error is thrown if `xpath` is not a simple XPath.
   *
   * @param {string} xpath
   * @param {Element} root
   * @return {Element|null}
   */
  function evaluateSimpleXPath(xpath, root) {
    const isSimpleXPath =
      xpath.match(/^(\/[A-Za-z0-9-]+(\[[0-9]+\])?)+$/) !== null;
    if (!isSimpleXPath) {
      throw new Error('Expression is not a simple XPath');
    }
  
    const segments = xpath.split('/');
    let element = root;
  
    // Remove leading empty segment. The regex above validates that the XPath
    // has at least two segments, with the first being empty and the others non-empty.
    segments.shift();
  
    for (let segment of segments) {
      let elementName;
      let elementIndex;
  
      const separatorPos = segment.indexOf('[');
      if (separatorPos !== -1) {
        elementName = segment.slice(0, separatorPos);
  
        const indexStr = segment.slice(separatorPos + 1, segment.indexOf(']'));
        elementIndex = parseInt(indexStr) - 1;
        if (elementIndex < 0) {
          return null;
        }
      } else {
        elementName = segment;
        elementIndex = 0;
      }
  
      const child = nthChildOfType(element, elementName, elementIndex);
      if (!child) {
        return null;
      }
  
      element = child;
    }
  
    return element;
  }
  
  /**
   * Finds an element node using an XPath relative to `root`
   *
   * Example:
   *   node = nodeFromXPath('/main/article[1]/p[3]', document.body)
   *
   * @param {string} xpath
   * @param {Element} [root]
   * @return {Node|null}
   */
  function nodeFromXPath(xpath, root = document.body) {
    try {
      return evaluateSimpleXPath(xpath, root);
    } catch (err) {
      return document.evaluate(
        '.' + xpath,
        root,
  
        // nb. The `namespaceResolver` and `result` arguments are optional in the spec
        // but required in Edge Legacy.
        null /* namespaceResolver */,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null /* result */
      ).singleNodeValue;
    }
  }
  
  /********************************************************
  ***** client/src/annotator/anchoring/match-quote.js  ****
  ********************************************************/
  
  /**
   * @typedef {import('approx-string-match').Match} StringMatch
   */
  
  /**
   * @typedef Match
   * @prop {number} start - Start offset of match in text
   * @prop {number} end - End offset of match in text
   * @prop {number} score -
   *   Score for the match between 0 and 1.0, where 1.0 indicates a perfect match
   *   for the quote and context.
   */
  
  /**
   * Find the best approximate matches for `str` in `text` allowing up to `maxErrors` errors.
   *
   * @param {string} text
   * @param {string} str
   * @param {number} maxErrors
   * @return {StringMatch[]}
   */
  function search(text, str, maxErrors) {
    // Do a fast search for exact matches. The `approx-string-match` library
    // doesn't currently incorporate this optimization itself.
    let matchPos = 0;
    let exactMatches = [];
    while (matchPos !== -1) {
      matchPos = text.indexOf(str, matchPos);
      if (matchPos !== -1) {
        exactMatches.push({
          start: matchPos,
          end: matchPos + str.length,
          errors: 0,
        });
        matchPos += 1;
      }
    }
    
    return exactMatches;
  }
  
  /**
   * Compute a score between 0 and 1.0 for the similarity between `text` and `str`.
   *
   * @param {string} text
   * @param {string} str
   */
  function textMatchScore(text, str) {
    // `search` will return no matches if either the text or pattern is empty,
    // otherwise it will return at least one match if the max allowed error count
    // is at least `str.length`.
    if (str.length === 0 || text.length === 0) {
      return 0.0;
    }
  
    const matches = search(text, str, str.length);
  
    // prettier-ignore
    return 1 - (matches[0].errors / str.length);
  }
  
  /**
   * Find the best approximate match for `quote` in `text`.
   *
   * Returns `null` if no match exceeding the minimum quality threshold was found.
   *
   * @param {string} text - Document text to search
   * @param {string} quote - String to find within `text`
   * @param {Object} context -
   *   Context in which the quote originally appeared. This is used to choose the
   *   best match.
   *   @param {string} [context.prefix] - Expected text before the quote
   *   @param {string} [context.suffix] - Expected text after the quote
   *   @param {number} [context.hint] - Expected offset of match within text
   * @return {Match|null}
   */
  function matchQuote(text, quote, context = {}) {
    if (quote.length === 0) {
      return null;
    }
  
    // Choose the maximum number of errors to allow for the initial search.
    // This choice involves a tradeoff between:
    //
    //  - Recall (proportion of "good" matches found)
    //  - Precision (proportion of matches found which are "good")
    //  - Cost of the initial search and of processing the candidate matches [1]
    //
    // [1] Specifically, the expected-time complexity of the initial search is
    //     `O((maxErrors / 32) * text.length)`. See `approx-string-match` docs.
    const maxErrors = Math.min(256, quote.length / 2);
  
    // Find closest matches for `quote` in `text` based on edit distance.
    const matches = search(text, quote, maxErrors);
  
    if (matches.length === 0) {
      return null;
    }
  
    /**
     * Compute a score between 0 and 1.0 for a match candidate.
     *
     * @param {StringMatch} match
     */
    const scoreMatch = match => {
      const quoteWeight = 50; // Similarity of matched text to quote.
      const prefixWeight = 20; // Similarity of text before matched text to `context.prefix`.
      const suffixWeight = 20; // Similarity of text after matched text to `context.suffix`.
      const posWeight = 2; // Proximity to expected location. Used as a tie-breaker.
  
      const quoteScore = 1 - match.errors / quote.length;
  
      const prefixScore = context.prefix
        ? textMatchScore(
            text.slice(
              Math.max(0, match.start - context.prefix.length),
              match.start
            ),
            context.prefix
          )
        : 1.0;
      const suffixScore = context.suffix
        ? textMatchScore(
            text.slice(match.end, match.end + context.suffix.length),
            context.suffix
          )
        : 1.0;
  
      let posScore = 1.0;
      if (typeof context.hint === 'number') {
        const offset = Math.abs(match.start - context.hint);
        posScore = 1.0 - offset / text.length;
      }
  
      const rawScore =
        quoteWeight * quoteScore +
        prefixWeight * prefixScore +
        suffixWeight * suffixScore +
        posWeight * posScore;
      const maxScore = quoteWeight + prefixWeight + suffixWeight + posWeight;
      const normalizedScore = rawScore / maxScore;
  
      return normalizedScore;
    };
  
    // Rank matches based on similarity of actual and expected surrounding text
    // and actual/expected offset in the document text.
    const scoredMatches = matches.map(m => ({
      start: m.start,
      end: m.end,
      score: scoreMatch(m),
    }));
  
    // Choose match with highest score.
    scoredMatches.sort((a, b) => b.score - a.score);
    return scoredMatches[0];
  }
  
  /********************************************************
  ********** client/src/annotator/range-util.js  **********
  ********************************************************/
  
  /**
   * Returns true if the start point of a selection occurs after the end point,
   * in document order.
   *
   * @param {Selection} selection
   */
  function isSelectionBackwards(selection) {
    if (selection.focusNode === selection.anchorNode) {
      return selection.focusOffset < selection.anchorOffset;
    }
  
    const range = selection.getRangeAt(0);
    // Does not work correctly on iOS when selecting nodes backwards.
    // https://bugs.webkit.org/show_bug.cgi?id=220523
    return range.startContainer === selection.focusNode;
  }
  
  /**
   * Returns true if any part of `node` lies within `range`.
   *
   * @param {Range} range
   * @param {Node} node
   */
  function isNodeInRange(range, node) {
    try {
      const length = node.nodeValue?.length ?? node.childNodes.length;
      return (
        // Check start of node is before end of range.
        range.comparePoint(node, 0) <= 0 &&
        // Check end of node is after start of range.
        range.comparePoint(node, length) >= 0
      );
    } catch (e) {
      // `comparePoint` may fail if the `range` and `node` do not share a common
      // ancestor or `node` is a doctype.
      return false;
    }
  }
  
  /**
   * Iterate over all Node(s) which overlap `range` in document order and invoke
   * `callback` for each of them.
   *
   * @param {Range} range
   * @param {(n: Node) => any} callback
   */
  function forEachNodeInRange(range, callback) {
    const root = range.commonAncestorContainer;
    const nodeIter = /** @type {Document} */ (
      root.ownerDocument
    ).createNodeIterator(root, NodeFilter.SHOW_ALL);
  
    let currentNode;
    while ((currentNode = nodeIter.nextNode())) {
      if (isNodeInRange(range, currentNode)) {
        callback(currentNode);
      }
    }
  }
  
  /**
   * Returns the bounding rectangles of non-whitespace text nodes in `range`.
   *
   * @param {Range} range
   * @return {Array<DOMRect>} Array of bounding rects in viewport coordinates.
   */
  function getTextBoundingBoxes(range) {
    const whitespaceOnly = /^\s*$/;
    const textNodes = [];
    forEachNodeInRange(range, function (node) {
      if (
        node.nodeType === Node.TEXT_NODE &&
        !(/** @type {string} */ (node.textContent).match(whitespaceOnly))
      ) {
        textNodes.push(node);
      }
    });
  
    let rects = [];
    textNodes.forEach(function (node) {
      const nodeRange = node.ownerDocument.createRange();
      nodeRange.selectNodeContents(node);
      if (node === range.startContainer) {
        nodeRange.setStart(node, range.startOffset);
      }
      if (node === range.endContainer) {
        nodeRange.setEnd(node, range.endOffset);
      }
      if (nodeRange.collapsed) {
        // If the range ends at the start of this text node or starts at the end
        // of this node then do not include it.
        return;
      }
  
      // Measure the range and translate from viewport to document coordinates
      const viewportRects = Array.from(nodeRange.getClientRects());
      nodeRange.detach();
      rects = rects.concat(viewportRects);
    });
    return rects;
  }
  
  /**
   * Returns the rectangle, in viewport coordinates, for the line of text
   * containing the focus point of a Selection.
   *
   * Returns null if the selection is empty.
   *
   * @param {Selection} selection
   * @return {DOMRect|null}
   */
  function selectionFocusRect(selection) {
    if (selection.isCollapsed) {
      return null;
    }
    const textBoxes = getTextBoundingBoxes(selection.getRangeAt(0));
    if (textBoxes.length === 0) {
      return null;
    }
  
    if (isSelectionBackwards(selection)) {
      return textBoxes[0];
    } else {
      return textBoxes[textBoxes.length - 1];
    }
  }
  
  /**
   * Retrieve a set of items associated with nodes in a given range.
   *
   * An `item` can be any data that the caller wishes to compute from or associate
   * with a node. Only unique items, as determined by `Object.is`, are returned.
   *
   * @template T
   * @param {Range} range
   * @param {(n: Node) => T} itemForNode - Callback returning the item for a given node
   * @return {T[]} items
   */
  function itemsForRange(range, itemForNode) {
    const checkedNodes = new Set();
    const items = new Set();
  
    forEachNodeInRange(range, node => {
      /** @type {Node|null} */
      let current = node;
      while (current) {
        if (checkedNodes.has(current)) {
          break;
        }
        checkedNodes.add(current);
  
        const item = itemForNode(current);
        if (item) {
          items.add(item);
        }
  
        current = current.parentNode;
      }
    });
  
    return [...items];
  }
  
  /********************************************************
  **** client/src/annotator/anchoring/placeholder.js  *****
  ********************************************************/
  
  /**
   * CSS selector that will match the placeholder within a page/tile container.
   */
  const placeholderSelector = '.annotator-placeholder';
  
  /**
   * Create or return a placeholder element for anchoring.
   *
   * In document viewers such as PDF.js which only render a subset of long
   * documents at a time, it may not be possible to anchor annotations to the
   * actual text in pages which are off-screen. For these non-rendered pages,
   * a "placeholder" element is created in the approximate X/Y location (eg.
   * middle of the page) where the content will appear. Any highlights for that
   * page are then rendered inside the placeholder.
   *
   * When the viewport is scrolled to the non-rendered page, the placeholder
   * is removed and annotations are re-anchored to the real content.
   *
   * @param {HTMLElement} container - The container element for the page or tile
   *   which is not rendered.
   */
  function createPlaceholder(container) {
    let placeholder = container.querySelector(placeholderSelector);
    if (placeholder) {
      return placeholder;
    }
    placeholder = document.createElement('span');
    placeholder.classList.add('annotator-placeholder');
    placeholder.textContent = 'Loading annotations...';
    container.appendChild(placeholder);
    return placeholder;
  }
  
  /**
   * Return true if a page/tile container has a placeholder.
   *
   * @param {HTMLElement} container
   */
  function hasPlaceholder(container) {
    return container.querySelector(placeholderSelector) !== null;
  }
  
  /**
   * Remove the placeholder element in `container`, if present.
   *
   * @param {HTMLElement} container
   */
  function removePlaceholder(container) {
    container.querySelector(placeholderSelector)?.remove();
  }
  
  /**
   * Return true if `node` is inside a placeholder element created with `createPlaceholder`.
   *
   * This is typically used to test if a highlight element associated with an
   * anchor is inside a placeholder.
   *
   * @param {Node} node
   */
  function isInPlaceholder(node) {
    if (!node.parentElement) {
      return false;
    }
    return node.parentElement.closest(placeholderSelector) !== null;
  }
  
  /********************************************************
  ********** client/src/annotator/highlighter.js   ********
  ********************************************************/
  
  const SVG_NAMESPACE = 'http://www.w3.org/2000/svg';

  /**
   * Return the canvas element underneath a highlight element in a PDF page's
   * text layer.
   *
   * Returns `null` if the highlight is not above a PDF canvas.
   *
   * @param {HTMLElement} highlightEl -
   *   A `<hypothesis-highlight>` element in the page's text layer
   * @return {HTMLCanvasElement|null}
   */
  function getPdfCanvas(highlightEl) {
    // This code assumes that PDF.js renders pages with a structure like:
    //
    // <div class="page">
    //   <div class="canvasWrapper">
    //     <canvas></canvas> <!-- The rendered PDF page -->
    //   </div>
    //   <div class="textLayer">
    //      <!-- Transparent text layer with text spans used to enable text selection -->
    //   </div>
    // </div>
    //
    // It also assumes that the `highlightEl` element is somewhere under
    // the `.textLayer` div.
  
    const pageEl = highlightEl.closest('.page');
    if (!pageEl) {
      return null;
    }
  
    const canvasEl = pageEl.querySelector('.canvasWrapper > canvas');
    if (!canvasEl) {
      return null;
    }
  
    return /** @type {HTMLCanvasElement} */ (canvasEl);
  }
  
  /**
   * Draw highlights in an SVG layer overlaid on top of a PDF.js canvas.
   *
   * Returns `null` if `highlightEl` is not above a PDF.js page canvas.
   *
   * @param {HTMLElement} highlightEl -
   *   An element that wraps the highlighted text in the transparent text layer
   *   above the PDF.
   * @return {SVGElement|null} -
   *   The SVG graphic element that corresponds to the highlight or `null` if
   *   no PDF page was found below the highlight.
   */
  function drawHighlightsAbovePdfCanvas(highlightEl) {
    const canvasEl = getPdfCanvas(highlightEl);
    if (!canvasEl || !canvasEl.parentElement) {
      return null;
    }
  
    /** @type {SVGElement|null} */
    let svgHighlightLayer = canvasEl.parentElement.querySelector(
      '.hypothesis-highlight-layer'
    );
  
    const isCssBlendSupported = CSS.supports('mix-blend-mode', 'multiply');
  
    if (!svgHighlightLayer) {
      // Create SVG layer. This must be in the same stacking context as
      // the canvas so that CSS `mix-blend-mode` can be used to control how SVG
      // content blends with the canvas below.
      svgHighlightLayer = document.createElementNS(SVG_NAMESPACE, 'svg');
      svgHighlightLayer.setAttribute('class', 'hypothesis-highlight-layer');
      canvasEl.parentElement.appendChild(svgHighlightLayer);
  
      // Overlay SVG layer above canvas.
      canvasEl.parentElement.style.position = 'relative';
  
      const svgStyle = svgHighlightLayer.style;
      svgStyle.position = 'absolute';
      svgStyle.left = '0';
      svgStyle.top = '0';
      svgStyle.width = '100%';
      svgStyle.height = '100%';
  
      if (isCssBlendSupported) {
        // Use multiply blending so that highlights drawn on top of text darken it
        // rather than making it lighter. This improves contrast and thus readability
        // of highlighted text, especially for overlapping highlights.
        //
        // This choice optimizes for the common case of dark text on a light background.
        //
        // @ts-ignore - `mixBlendMode` property is missing from type definitions.
        svgStyle.mixBlendMode = 'multiply';
      } else {
        // For older browsers (eg. Edge < 79) we draw all the highlights as
        // opaque and then make the entire highlight layer transparent. This means
        // that there is no visual indication of whether text has one or multiple
        // highlights, but it preserves readability.
        svgStyle.opacity = '0.3';
      }
    }
  
    const canvasRect = canvasEl.getBoundingClientRect();
    const highlightRect = highlightEl.getBoundingClientRect();
  
    // Create SVG element for the current highlight element.
    const rect = document.createElementNS(SVG_NAMESPACE, 'rect');
    rect.setAttribute('x', (highlightRect.left - canvasRect.left).toString());
    rect.setAttribute('y', (highlightRect.top - canvasRect.top).toString());
    rect.setAttribute('width', highlightRect.width.toString());
    rect.setAttribute('height', highlightRect.height.toString());
  
    if (isCssBlendSupported) {
      rect.setAttribute('class', 'hypothesis-svg-highlight');
    } else {
      rect.setAttribute('class', 'hypothesis-svg-highlight is-opaque');
    }
  
    svgHighlightLayer.appendChild(rect);
  
    return rect;
  }
  
  /**
   * Additional properties added to text highlight HTML elements.
   *
   * @typedef HighlightProps
   * @prop {SVGElement} [svgHighlight]
   */
  
  /**
   * @typedef {HTMLElement & HighlightProps} HighlightElement
   */
  
  /**
   * Return text nodes which are entirely inside `range`.
   *
   * If a range starts or ends part-way through a text node, the node is split
   * and the part inside the range is returned.
   *
   * @param {Range} range
   * @return {Text[]}
   */
  function wholeTextNodesInRange(range) {
    if (range.collapsed) {
      // Exit early for an empty range to avoid an edge case that breaks the algorithm
      // below. Splitting a text node at the start of an empty range can leave the
      // range ending in the left part rather than the right part.
      return [];
    }
  
    /** @type {Node|null} */
    let root = range.commonAncestorContainer;
    if (root.nodeType !== Node.ELEMENT_NODE) {
      // If the common ancestor is not an element, set it to the parent element to
      // ensure that the loop below visits any text nodes generated by splitting
      // the common ancestor.
      //
      // Note that `parentElement` may be `null`.
      root = root.parentElement;
    }
    if (!root) {
      // If there is no root element then we won't be able to insert highlights,
      // so exit here.
      return [];
    }
  
    const textNodes = [];
    const nodeIter = /** @type {Document} */ (
      root.ownerDocument
    ).createNodeIterator(
      root,
      NodeFilter.SHOW_TEXT // Only return `Text` nodes.
    );
    let node;
    while ((node = nodeIter.nextNode())) {
      if (!isNodeInRange(range, node)) {
        continue;
      }
      let text = /** @type {Text} */ (node);
  
      if (text === range.startContainer && range.startOffset > 0) {
        // Split `text` where the range starts. The split will create a new `Text`
        // node which will be in the range and will be visited in the next loop iteration.
        text.splitText(range.startOffset);
        continue;
      }
  
      if (text === range.endContainer && range.endOffset < text.data.length) {
        // Split `text` where the range ends, leaving it as the part in the range.
        text.splitText(range.endOffset);
      }
  
      textNodes.push(text);
    }
  
    return textNodes;
  }
  
  /**
   * Wraps the DOM Nodes within the provided range with a highlight
   * element of the specified class and returns the highlight Elements.
   *
   * @param {Range} range - Range to be highlighted
   * @param {string} cssClass - A CSS class to use for the highlight
   * @return {HighlightElement[]} - Elements wrapping text in `normedRange` to add a highlight effect
   */
  function highlightRange(range, cssClass = 'hypothesis-highlight') {
    const textNodes = wholeTextNodesInRange(range);
  
    // Check if this range refers to a placeholder for not-yet-rendered content in
    // a PDF. These highlights should be invisible.
    const inPlaceholder = textNodes.length > 0 && isInPlaceholder(textNodes[0]);
  
    // Group text nodes into spans of adjacent nodes. If a group of text nodes are
    // adjacent, we only need to create one highlight element for the group.
    let textNodeSpans = [];
    let prevNode = null;
    let currentSpan = null;
  
    textNodes.forEach(node => {
      if (prevNode && prevNode.nextSibling === node) {
        currentSpan.push(node);
      } else {
        currentSpan = [node];
        textNodeSpans.push(currentSpan);
      }
      prevNode = node;
    });
  
    // Filter out text node spans that consist only of white space. This avoids
    // inserting highlight elements in places that can only contain a restricted
    // subset of nodes such as table rows and lists.
    const whitespace = /^\s*$/;
    textNodeSpans = textNodeSpans.filter(span =>
      // Check for at least one text node with non-space content.
      span.some(node => !whitespace.test(node.nodeValue))
    );
  
    // Wrap each text node span with a `<hypothesis-highlight>` element.
    const highlights = [];
    textNodeSpans.forEach(nodes => {
      // A custom element name is used here rather than `<span>` to reduce the
      // likelihood of highlights being hidden by page styling.
  
      /** @type {HighlightElement} */
      const highlightEl = document.createElement('hypothesis-highlight');
      highlightEl.className = cssClass;
  
      nodes[0].parentNode.replaceChild(highlightEl, nodes[0]);
      nodes.forEach(node => highlightEl.appendChild(node));
  
      if (!inPlaceholder) {
        // For PDF highlights, create the highlight effect by using an SVG placed
        // above the page's canvas rather than CSS `background-color` on the
        // highlight element. This enables more control over blending of the
        // highlight with the content below.
        const svgHighlight = drawHighlightsAbovePdfCanvas(highlightEl);
        if (svgHighlight) {
          highlightEl.className += ' is-transparent';
  
          // Associate SVG element with highlight for use by `removeHighlights`.
          highlightEl.svgHighlight = svgHighlight;
        }
      }
  
      highlights.push(highlightEl);
    });
  
    return highlights;
  }
  
  /**
   * Replace a child `node` with `replacements`.
   *
   * nb. This is like `ChildNode.replaceWith` but it works in older browsers.
   *
   * @param {ChildNode} node
   * @param {Node[]} replacements
   */
  function replaceWith(node, replacements) {
    const parent = /** @type {Node} */ (node.parentNode);
    replacements.forEach(r => parent.insertBefore(r, node));
    node.remove();
  }
  
  /**
   * Remove all highlights under a given root element.
   *
   * @param {HTMLElement} root
   */
  function removeAllHighlights(root) {
    const highlights = Array.from(root.querySelectorAll('hypothesis-highlight'));
    removeHighlights(/** @type {HighlightElement[]} */ (highlights));
  }
  
  /**
   * Remove highlights from a range previously highlighted with `highlightRange`.
   *
   * @param {HighlightElement[]} highlights - The highlight elements returned by `highlightRange`
   */
  function removeHighlights(highlights) {
    for (let h of highlights) {
      if (h.parentNode) {
        const children = Array.from(h.childNodes);
        replaceWith(h, children);
      }
  
      if (h.svgHighlight) {
        h.svgHighlight.remove();
      }
    }
  }
  
  /**
   * Set whether the given highlight elements should appear "focused".
   *
   * A highlight can be displayed in a different ("focused") style to indicate
   * that it is current in some other context - for example the user has selected
   * the corresponding annotation in the sidebar.
   *
   * @param {HighlightElement[]} highlights
   * @param {boolean} focused
   */
  function setHighlightsFocused(highlights, focused) {
    highlights.forEach(h => {
      // In PDFs the visible highlight is created by an SVG element, so the focused
      // effect is applied to that. In other documents the effect is applied to the
      // `<hypothesis-highlight>` element.
      if (h.svgHighlight) {
        h.svgHighlight.classList.toggle('is-focused', focused);
      } else {
        h.classList.toggle('hypothesis-highlight-focused', focused);
      }
    });
  }
  
  /**
   * Set whether highlights under the given root element should be visible.
   *
   * @param {HTMLElement} root
   * @param {boolean} visible
   */
  function setHighlightsVisible(root, visible) {
    const showHighlightsClass = 'hypothesis-highlights-always-on';
    root.classList.toggle(showHighlightsClass, visible);
  }
  
  /**
   * Get the highlight elements that contain the given node.
   *
   * @param {Node} node
   * @return {HighlightElement[]}
   */
  function getHighlightsContainingNode(node) {
    let el =
      node.nodeType === Node.ELEMENT_NODE
        ? /** @type {Element} */ (node)
        : node.parentElement;
  
    const highlights = [];
  
    while (el) {
      if (el.classList.contains('hypothesis-highlight')) {
        highlights.push(/** @type {HighlightElement} */ (el));
      }
      el = el.parentElement;
    }
  
    return highlights;
  }
  
  /**
   * Subset of `DOMRect` interface.
   *
   * @typedef Rect
   * @prop {number} top
   * @prop {number} left
   * @prop {number} bottom
   * @prop {number} right
   */
  
  /**
   * Get the bounding client rectangle of a collection in viewport coordinates.
   * Unfortunately, Chrome has issues ([1]) with Range.getBoundingClient rect or we
   * could just use that.
   *
   * [1] https://bugs.chromium.org/p/chromium/issues/detail?id=324437
   *
   * @param {HTMLElement[]} collection
   * @return {Rect}
   */
  function getBoundingClientRect(collection) {
    // Reduce the client rectangles of the highlights to a bounding box
    const rects = collection.map(
      n => /** @type {Rect} */ (n.getBoundingClientRect())
    );
    return rects.reduce((acc, r) => ({
      top: Math.min(acc.top, r.top),
      left: Math.min(acc.left, r.left),
      bottom: Math.max(acc.bottom, r.bottom),
      right: Math.max(acc.right, r.right),
    }));
  }
  
  """;
}
