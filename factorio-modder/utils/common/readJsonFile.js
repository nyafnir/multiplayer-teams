import { readFileSync } from "fs";

/**
 * @param {string} pathToFile (без .<расширение>)
 * @returns {object}
 */
export function readJsonFile(pathToFile) {
  return JSON.parse(readFileSync(`${pathToFile}.json`, "utf8"));
}
