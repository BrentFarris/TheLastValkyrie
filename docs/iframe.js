if (navigator.userAgent.includes('Firefox')) {
    var request = new XMLHttpRequest();
    request.open('GET', 'view.html', true);
    request.onload = function() {
        if (request.status >= 200 && request.status < 400) {
            var resp = request.responseText;
            document.querySelector('#post').innerHTML = resp;
            let anchors = document.querySelector('#post').querySelectorAll('a');
            for (let i = 0; i < anchors.length; ++i) {
                if (anchors[i].href.indexOf("retroscience.net") >= 0 && anchors[i].href.indexOf("#") === -1)
                    anchors[i].target = "_parent";
                else if (anchors[i].href.indexOf("youtube.com/embed/") > 0)
                    anchors[i].innerHTML = '<iframe width="560" height="315" src="' + anchors[i].href + '" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
            }
        }
    };
    request.send();
} else {
    let lastHeight = 0;
    function resize() {
        let f = document.getElementById("view");
        let h = f.contentWindow.document.body.scrollHeight;
        if (h != f.height)
            f.height = h;
    }
    function iframeLoad() {
        let f = document.getElementById("view");
        f.height = f.contentWindow.document.body.scrollHeight;
        let frameHead = f.contentDocument.getElementsByTagName("head")[0];
        let link = f.contentDocument.createElement("link");
        link.type = "text/css";
        link.rel = "stylesheet";
        link.href = "../iframestyle.css";
        frameHead.appendChild(link);
        let anchors = f.contentDocument.querySelectorAll('a');
        for (let i = 0; i < anchors.length; ++i) {
            if (anchors[i].href.indexOf("retroscience.net") >= 0 && anchors[i].href.indexOf("#") === -1)
                anchors[i].target = "_parent";
            else if (anchors[i].href.indexOf("youtube.com/embed/") > 0)
                anchors[i].innerHTML = '<iframe width="560" height="315" src="' + anchors[i].href + '" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
        }
        setInterval(resize, 1000);
    }
    window.onload = function() {
        let f = document.getElementById("view");
        if (!f) return;
        let cw = f.contentWindow;
        if ((f.src == "about:blank" || (f.src != "about:blank" && cw.location.href != "about:blank"))
            && cw.document.readyState == "complete") {
            iframeLoad();
        } else
            cw.addEventListener("load", iframeLoad);
    }
}
