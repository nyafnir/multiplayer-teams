import { writeFileSync } from "fs";

/**
 * @param {string} pathToFile
 * @param {object} data
 * @returns {void}
 */
export function writeJsonFile(pathToFile, data) {
  writeFileSync(pathToFile, JSON.stringify(data, null, 2), "utf8");
}
