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

	let itemOnClick = (e) => {
		sidebar_items.forEach( _it => {
			_it.classList.remove("active");
		});
		e.target.classList.add("active");

		let txt = e.target.innerText.trim();
		if (txt.includes('Executables'))
		{
			reports.forEach((htmlElem, id) => {
				htmlElem.hidden = (id != "report_objects");
			});
			document.getElementById('report_objects').scrollIntoView()
		}
		else if (txt.includes('Libraries'))
		{
			reports.forEach((htmlElem, id) => {
				htmlElem.hidden = (id != "report_objects");
			});
			document.getElementById('report_objects').scrollIntoView()
		}
		else if (txt.includes('Warnings'))
		{
			reports.forEach((htmlElem, id) => {
				htmlElem.hidden = (id != "report_warnings");
			});
			document.getElementById('report_warnings').scrollIntoView()
		}
		else if (txt.includes('Statistics'))
		{
			reports.forEach((htmlElem, id) => {
				htmlElem.hidden = (id != "report_objects");
			});
			document.getElementById('report_objects').scrollIntoView()
		}
		else if (txt.includes('System informations'))
		{
			reports.forEach((htmlElem, id) => {
				htmlElem.hidden = (id != "report_sys_info");
			});
			document.getElementById('report_sys_info').scrollIntoView()
		}
	}

	sidebar_items.forEach(item => {
		item.parentElement.addEventListener("click", itemOnClick);
	});

	let nb_of_warnings = 0;

	for (let elf of document.getElementsByClassName("elf"))
	{
		let undef = elf.getElementsByClassName("undef_symbols");
		if (undef.length <= 0)
			continue;

		nb_of_warnings += 1;

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
		footer.innerText = 'Missing objects detected with \'ldd -r\'.'

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

	if (nb_of_warnings == 0)
	{
		sidebar_items.forEach(item => {
			if (item.innerText.trim() == "Warnings")
			{ let classList = item.getAttribute('class');
				item.setAttribute('class', classList + ' item-disabled');
				item.parentElement.removeEventListener('click', itemOnClick);
				return;
			}
		});
	}
	else
	{
		let pill = document.getElementById('menu_warn_nb');
		pill.innerText = nb_of_warnings;
	}
};

