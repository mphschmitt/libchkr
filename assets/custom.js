/* All custom js code goes here */

window.onload = () => {
	let sidebar = document.getElementById("sidebar");
	let sidebar_items = Array.from(sidebar.getElementsByClassName("menu-link"));
	/* Build a hashmap of the main <div> that have an equivalent to the
	 * navigation items in the sidebar. This allows an access in O(1) to
	 * these elements instead of O(n) */
	let reports = new Map();
	for (let report of document.getElementsByClassName("report"))
		reports.set(report.id, report);

	sidebar_items.forEach(item => {
		item.addEventListener("click", e => {
			sidebar_items.forEach( _it => {
				_it.classList.remove("active");
			});
			item.classList.add("active");

			switch(item.innerText.trim())
			{
				case "Executables":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_objects");
					});
					break;
				case "Libraries":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_objects");
					});
					break;
				case "Warnings":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_objects");
					});
					break;
				case "Statistics":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_objects");
					});
					break;
				case "System informations":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_sys_info");
					});
					break;
				default:
					break;
			};
		});
	});
};

