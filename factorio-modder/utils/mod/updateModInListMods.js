import { readJsonFile, writeJsonFile } from "../common";

/**
 * @param {string} pathToAppDataFactorioDir
 * @param {string} modName
 * @param {boolean} [enabled]
 * @param {boolean} [needDeleteByDisabled]
 * @returns {void}
 */
export function updateModInListMods(
  pathToModsDir,
  modName,
  enabled = true,
  needDeleteByDisabled = true
) {
  const pathToModListFile = `${pathToModsDir}/mod-list`;

  /**
   * @type {{ mods: { name: string; enabled: boolean; }[] }}
   */
  const modList = readJsonFile(pathToModListFile);

  let modIndex = modList.mods.findIndex((mod) => mod.name === modName);

  if (modIndex === -1) {
    modList.mods.push({
      name: modName,
      enabled,
    });
  } else {
    modList.mods[modIndex].enabled = enabled;
  }

  if (needDeleteByDisabled) {
    delete modList.mods[modIndex];
  }

  writeJsonFile(pathToModListFile, modList);
}
