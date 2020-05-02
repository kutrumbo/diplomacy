import React from 'react'
import { find, snakeCase } from 'lodash';

function PositionIcon({ areas, coasts, positions, userGames }) {
  const areaName = snakeCase(areas[positions[0].area_id].name);
  const coastDirection = positions[0].coast_id && coasts[positions[0].coast_id].direction;
  const areaClass = coastDirection ? `${areaName}_${coastDirection}` : areaName;
  if (positions.length === 1) {
    const position = positions[0];
    const classNames = ['icon', 'icon-map', 'is-medium', areaClass];
    const power = userGames[position.user_game_id].power;
    classNames.push(power);
    if (position.power == power) {
      classNames.push('occupied');
    }
    if (position.type) {
      classNames.push(position.type);
    }
    return (
      <span className={classNames.join(' ')} />
    );
  } else {
    const unitPosition = find(positions, position => position.type && !position.dislodged);
    const unitPower = userGames[unitPosition.user_game_id].power;
    const unitClassNames = ['icon', 'icon-map', 'is-medium', areaClass, unitPower, unitPosition.type];
    const areaPosition = find(positions, position => !position.type || position.dislodged);
    const areaPower = userGames[areaPosition.user_game_id].power;
    const areaClassNames = ['icon', 'icon-map', 'is-medium', 'occupied-area', areaClass, areaPower];
    if (areaPosition.dislodged) {
      areaClassNames.push('dislodged');
    }

    return (
      <>
        <span className={areaClassNames.join(' ')} />
        <span className={unitClassNames.join(' ')} />
      </>
    );
  }
}

export default function PositionMap(props) {
  // props.positions is an array of positions for all areas with a position
  return (
    <div className="container-map">
      <img src={props.map_path} />
      {props.positions.map(positions =>
        <PositionIcon
          key={positions[0].area_id}
          areas={props.areas}
          coasts={props.coasts}
          positions={positions}
          userGames={props.user_games} />
      )}
    </div>
  );
}
