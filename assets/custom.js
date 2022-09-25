/* All custom js code goes here */

window.onload = () => {
	let sidebar = document.getElementById("sidebar");
	let sidebar_items = Array.from(sidebar.getElementsByClassName("menu-link"));

	sidebar_items.forEach(item => {
		item.addEventListener("click", e => {
			sidebar_items.forEach( _it => {
				_it.classList.remove("active");
			});
			item.classList.add("active");
		});
	});
};

