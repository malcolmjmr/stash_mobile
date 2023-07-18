
class RootDocument {
  constructor(links, annotations, sectionCount) {
    this.getInfo();
    this.setAnnotations(annotations);
    this.setLinks(links);
    this.getSections();
  }

  getInfo() {
    this.title = document.title;
    this.href = window.location.href;
    // notify handler
  }

  setLinks(links) {
    this.links = links;
  }

  setAnnotations(annotations) {
    this.annotations = annotations;
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

    if (sectionCount != this.sections.length) {
        // notify handler
    }

  }

  getContent(element) {

    if (element.innerText == null || element.innerText == '') return;

    let currentSection = this.sections[this.sectionIndex];
    let tagName = element.tagName.toLowerCase();
    let isText = ['p','span','ul','ol','blockquote'].includes(tagName);
    if (isText) {
      // Todo: add links  {'text': '', 'href': ''}
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
}

let rootDoc = new RootDocument([]);