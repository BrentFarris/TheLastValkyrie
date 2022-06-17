(function() {
	let body = document.getElementById("content");
	function create_article(info) {
		let article = document.createElement("div");
		article.className = "article";
		article.innerHTML = `<div></div><a href="${info.path}"><h2>${info.title}</h2></a><p>${info.description}</p>`;
		if (info.image) {
			let div = article.firstChild;
			div.innerHTML = `<a href="/${info.path}"><img src="${info.image}" /></a>`;
		}
		body.appendChild(article);
	}

	function read(json) {
		let arr = [];
		for (let i = 0; i < json.length; ++i)
			if (json[i].date != "0000-00-00")
				arr.push(json[i]);
		arr.sort(function(a, b) { return new Date(b.date) - new Date(a.date); });
		for (let i = 0; i < arr.length; ++i)
			create_article(arr[i]);
	}

	function get_json() {
		var req = new XMLHttpRequest();
		req.open("GET", "../md.json", true);
		req.onload = function() {
			if (req.status >= 200 && req.status < 400)
				read(JSON.parse(req.responseText));
		}
		req.send();
	}

	get_json();
})();
