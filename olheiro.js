var els = [];
for(var i in tweets) {var iframeDocument = tweets[i].contentDocument || tweets[i].contentWindow.document; var iframeContent;

if (iframeDocument) {
    iframeContent = iframeDocument.getElementsByClassName('Tweet-text');
console.log(iframeContent.item(0));
console.log(iframeContent.item(0).innerHTML);
els.push(iframeContent.item(0).textContent);
}}

console.log(els);