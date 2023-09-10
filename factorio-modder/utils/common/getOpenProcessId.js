import psList from "ps-list";

/**
 * @param {string} processName
 * @returns {Promise<string | undefined>}
 */
export async function getOpenProcessId(processName) {
  const list = await psList();
  const game = list.find((process) => process.name === processName);
  return game?.pid;
}
