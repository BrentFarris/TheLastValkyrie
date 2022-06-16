(function() {
	let body = document.getElementById("content");
	function create_article(info) {
		let article = document.createElement("div");
		article.className = "article";
		article.innerHTML = `<a href="/${info.path}"><div></div><h2>${info.title}</h2></a><p>${info.description}</p>`;
		if (info.image) {
			let div = article.firstChild;
			div.innerHTML = `<img src="${info.image}" />`;
		}
		body.appendChild(article);
	}

	function read(json) {
		for (let i = 0; i < json.length; ++i)
			create_article(json[i]);
	}

	function get_json() {
		var req = new XMLHttpRequest();
		req.open("GET", "../search.json", true);
		req.onload = function() {
			if (req.status >= 200 && req.status < 400)
				read(JSON.parse(req.responseText));
		}
		req.send();
	}

	get_json();
})();
