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
					document.getElementById('report_objects').scrollIntoView()
					break;
				case "Libraries":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_objects");
					});
					document.getElementById('report_objects').scrollIntoView()
					break;
				case "Warnings":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_warnings");
					});
					document.getElementById('report_warnings').scrollIntoView()
					break;
				case "Statistics":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_objects");
					});
					document.getElementById('report_objects').scrollIntoView()
					break;
				case "System informations":
					reports.forEach((htmlElem, id) => {
						htmlElem.hidden = (id != "report_sys_info");
					});
					document.getElementById('report_sys_info').scrollIntoView()
					break;
				default:
					break;
			};
		});
	});

	for (let elf of document.getElementsByClassName("elf"))
	{
		let undef = elf.getElementsByClassName("undef_symbols");
		if (undef.length <= 0)
			continue;

		/* Get number of undefined symbols. */
		let nb_symbls = undef.item(0).attributes.getNamedItem("sym_nb").nodeValue;

		/* Create card. */
		let card = document.createElement('div');
		card.setAttribute('class', 'card test-center');

		let card_header = document.createElement('div');
		card_header.setAttribute('class', 'card-header');
		card_header.innerText = 'Object with missing symbols.'

		let card_body = document.createElement('div');
		card_body.setAttribute('class', 'card-body');

		let h5 = document.createElement('h5');
		h5.setAttribute('class', 'card-title');
		h5.innerText = elf.getElementsByTagName("button")[0].innerText;

		let p = document.createElement('p');
		p.setAttribute('class', 'card-text');
		p.innerText = 'This object has ' + nb_symbls + ' undefined symbols after code relocation.'

		let a = document.createElement('a');
		a.setAttribute('class', 'btn btn-warning');
		a.innerText = 'Go to symbols list';

		let footer = document.createElement('div');
		footer.setAttribute('class', 'card-footer text-muted');
		footer.innerText = 'Missing objects detected with \'ldd -R\'.'

		card_body.appendChild(h5);
		card_body.appendChild(p);
		card_body.appendChild(a);
		card.appendChild(card_header);
		card.appendChild(card_body);
		card.appendChild(footer);
		reports.get('report_warnings').appendChild(card);

		a.addEventListener("click", e => {
			sidebar_items.forEach(item => {
				if (item.innerText.trim() == "Executables")
					item.click();
			});

			elf.scrollIntoView();

			let accordion_button = elf.getElementsByClassName('accordion-button').item(0);
			if (accordion_button.getAttribute('aria-expanded') == 'false')
				accordion_button.click(); /* Open dropdown */
		});
	}

};

