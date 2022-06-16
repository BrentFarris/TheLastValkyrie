(function() {
	let body = document.getElementById("content");
	function read(json) {
		console.log(json);
	}

	function get_json() {
		var req = new XMLHttpRequest();
		req.open("GET", "search.json", true);
		req.onload = function() {
			if (request.status >= 200 && request.status < 400)
				read(JSON.parse(req.responseText);
		}
	}

	get_json();
})();
