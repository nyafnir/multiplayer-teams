import AdmZip from "adm-zip";

const zipService = new AdmZip();

/**
 * @param {string} pathToSrcDir
 * @param {string} pathToOutDir
 * @param {string} modName
 * @param {string} version
 * @returns {string} pathToOutFile
 */
export function createModArchive(pathToSrcDir, pathToOutDir, modName, version) {
  const modFileName = `${modName}_${version}`;
  const pathToOutFile = `${pathToOutDir}\\${modFileName}.zip`;

  zipService.addLocalFolder(`${pathToSrcDir}`, `${modName}`);
  zipService.writeZip(pathToOutFile);

  return pathToOutFile;
}
