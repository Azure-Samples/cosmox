import { readFileSync } from "fs"

const file = readFileSync("./example-response-headers.json", "utf-8")

console.log(`content: ${file}`)

const filtered = JSON.parse(file.trim())
    .map(x => x.key)
    .join("\n")

console.log(filtered)