import { FactorioModBuilder } from "./builder.js";

(async () => {
  const builder = new FactorioModBuilder();
  await builder.closeGame();
  await builder.waitGameClosed(1);

  const modInfo = builder.getModInfo("../");
  builder.removeModFromMods(modInfo.name);
  builder.createModInMods("../", modInfo.name, modInfo.version);

  await builder.waitGameClosed(3);
  await builder.startGame();
})();
