/** @type {import("tailwindcss").Config} */
module.exports = {
	content : [
		"./app/**/*.{bx,bxm,cfc,cfm}",
		"./public/**/*.bx"
	],
	theme   : {
		extend : {
			colors    : {
				ink   : "#17202a",
				muted : "#5d6978",
				paper : "#f8f7f3",
				panel : "#ffffff",
				line  : "#d9ded8",
				green : "#246b57",
				blue  : "#246a96",
				gold  : "#b98524",
				field : "#fbfcfa",
				code  : "#eef3f1"
			},
			boxShadow : {
				panel : "0 16px 40px rgba(23, 32, 42, 0.06)",
				toast : "0 18px 50px rgba(23, 32, 42, 0.16)"
			},
			maxWidth  : {
				shell : "1120px"
			},
			screens   : {
				demo : "761px"
			}
		}
	}
};
