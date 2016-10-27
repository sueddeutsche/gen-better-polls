const fs = require("fs");

/**
 * Assemble and save the README.md from markdown files found in assets
 */
Promise
    .all([
        read("data/project.md"),
        read("data/article.md").then(renderTemplate),
        read("data/usage.md")
    ])
    .then((partials) => {
        return save("README.md", partials.join("\n"));
    });


function renderTemplate(template) {
    return template;
}

function read(filepath) {
    return new Promise((resolve, reject) => {
        fs.readFile(filepath, (err, contents) => {
            if (err) {
                return reject(err);
            }
            return resolve(contents.toString("utf8"));
        });
    });
}

function save(filepath, contents) {
    return new Promise((resolve, reject) => {
        fs.writeFile(filepath, contents, (err) => {
            if (err) {
                return reject(err);
            }
            return resolve();
        });
    });
}
