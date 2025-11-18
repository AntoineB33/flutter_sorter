
  
  void getEverything() {
    errorRoot = null;
    warningRoot = null;
    if (result.wasEdited) {
      let property;
      if (initialLoad || result.newSelectedRoleList.length > 0) {
        property = PropertiesService.getScriptProperties();
      }
      if (initialLoad) {
        result.roles = JSON.parse(property.getProperty("roles") || "[]");
        result.rolesOptions = Object.values(Roles);
      }
      if (result.newSelectedRoleList.length > 0) {
        let selId = 0;
        const origRoles = result.roles.slice();
        for (const newSelectedRole of result.newSelectedRoleList) {
          while (
            selId < selections.lenght &&
            selections[selId].date < newSelectedRole.date
          ) {
            selId++;
          }
          const col = selections.length > 0 ? selections[selId - 1].col : 0;
          if (col >= result.roles.length) {
            result.roles = result.roles.concat(
              Array(col - result.roles.length + 1).fill(result.rolesOptions[0]),
            );
          } else {
            for (
              let i = result.roles.length - 1;
              i > result.table[0].length - 1;
              i--
            ) {
              if (result.roles[i] === result.rolesOptions[0]) {
                result.roles.pop();
              } else {
                break;
              }
            }
          }
          if (col < result.roles.length) {
            result.roles[col] = newSelectedRole.value;
          }
        }
        result.newSelectedRoleList = [];
        if (JSON.stringify(origRoles) !== JSON.stringify(result.roles)) {
          property.setProperty("roles", JSON.stringify(result.roles));
        }
      }
      const sheet = SpreadsheetApp.getActiveSheet();
      result.table = sheet.getDataRange().getValues();
      result.name = sheet.getName();
      if (result.name === "s") {
        errorRoot.push(
          `Error: Invalid role '${result.name}' - 's' is a reserved name`,
        );
        return;
      }
      result.table.forEach((row) =>
        row.forEach((cell, idx) => {
          if (typeof cell !== "string") {
            row[idx] = String(cell);
          }
          row[idx] = row[idx].trim().toLowerCase();
        }),
      );
      normalize(result);
      const errorRoot = result.errorRoot;
      if (errorRoot.length > 0) {
        return result;
      }
      const table = result.table;
      const roles = result.roles;
      alph = generateUniqueStrings(Math.max(roles.length, table.length));
      result.nameIndexes = new Set();
      const pathIndexes = new Set();
      roles.forEach((role, index) => {
        if (role === Roles.NAMES) {
          result.nameIndexes.add(index);
        } else if (role === Roles.PATH) {
          pathIndexes.add(index);
        }
      });
      const nameIndex = result.nameIndexes.values().next().value;
      const pathIndex = pathIndexes.values().next().value;
      result.mentions = Array.from({ length: table.length }, () =>
        Array.from({ length: table[0].length }, () => []),
      );
      for (let i = 0; i < table.length; i++) {
        for (let j of [nameIndex, pathIndex]) {
          let cell_elements = table[i][j].split(";");
          for (let k = 0; k < cell_elements.length; k++) {
            cell_elements[k] = cell_elements[k].trim();
            if (j === nameIndex) {
              cell_elements[k] = cell_elements[k].toLowerCase();
            }
          }
          result.mentions[i][j] = cell_elements.filter((s) => s);
        }
      }
      for (let i = 1; i < table.length; i++) {
        for (const name of result.mentions[i][nameIndex]) {
          if (!isNaN(parseInt(name))) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} is not a valid name`,
            );
            return result;
          }

          const match = name.match(/ -(\w+)$/);
          if (
            name.includes("_") ||
            name.includes(":") ||
            name.includes("|") ||
            (match && !["fst", "lst"].includes(match[1]))
          ) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} contains invalid characters (_ : | -)`,
            );
          }

          const parenMatch = name.match(/(\(\d+\))$/);
          if (parenMatch) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} contains invalid parentheses`,
            );
          }

          if (["fst", "lst"].includes(name)) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: ${JSON.stringify(name)} is a reserved name`,
            );
          }

          if (name in result.names) {
            errorRoot.push(
              `Error in row ${i}, column ${alph[nameIndex]}: name ${JSON.stringify(name)} already exists in row ${result.names[name]}`,
            );
          }
          result.names[name] = i;
        }
      }
      result.table = table;
      result.nameIndex = nameIndex;
      result.pathIndex = pathIndex;
      getCategories(result);
    }
    if (debugEnabled) {
      debugToDoc(JSON.stringify(result));
    }
    result.alph = alph;
    return result;
  }
