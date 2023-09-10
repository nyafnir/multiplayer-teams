import { readJsonFile } from "../common";

/**
 * @param {string} pathToSrcDir
 * @returns {object}
 */
export function getModInfo(pathToSrcDir) {
  return readJsonFile(`${pathToSrcDir}/info`);
}
