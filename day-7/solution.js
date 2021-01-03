const readline = require('readline').createInterface({
	input: process.stdin,
	output: process.stdout,
	terminal: false
});

let bagCache = {};
readline.on('line', (line) => {
	let [_, color, innerBags] = line.match(/(.*) bags contain (.*)\./);
	let node = bagCache[color] || {
		color: color,
		inner: {},
		outer: []
	};

	innerBags.split(/,/).filter(s => !s.match(/no other bags/)).forEach(inner => {
		let [_, count, innerColor] = inner.match(/(\d+) (.*?) bags?/);
		let innerBag = bagCache[innerColor] = bagCache[innerColor] || {
			color: innerColor,
			inner: {},
			outer: []
		};

		innerBag.outer.push(node);
		node.inner[innerColor] = [innerBag, count];
	});

	bagCache[color] = node;
});

readline.on('close', () => {
	let visited = [];
	function recurseOuterBags(node) {
		let count = 0;
		for (let outer of node.outer) {
			if (!visited.includes(outer.color)) {
				count += 1 + recurseOuterBags(outer);
				visited.push(outer.color);
			}
		}

		return count;
	}

	function recurseInnerBags(node) {
		let count = 1;

		for (const [key, value] of Object.entries(node.inner)) {
			count += value[1] * recurseInnerBags(value[0]);
		}

		return count;
	}

	let shinyGoldBag = bagCache['shiny gold'];
	console.log(`[part 1] bags eventually containing shiny gold bag: ${recurseOuterBags(shinyGoldBag)}`);
	console.log(`[part 2] bags required inside shiny gold bag: ${recurseInnerBags(shinyGoldBag) - 1}`);
});

