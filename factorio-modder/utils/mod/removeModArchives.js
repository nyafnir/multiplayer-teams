import { deleteFilesByMask } from "../common";

/**
 * @param {string} pathToModsDir
 * @param {string} modName
 * @returns {void}
 */
export function removeModArchives(pathToModsDir, modName) {
  deleteFilesByMask(pathToModsDir, `${modName}.*`);
}
