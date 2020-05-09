import React, { useEffect, useState, } from 'react'
import { find, snakeCase } from 'lodash';

function calculateIconModifier(windowWidth) {
  if (windowWidth <= 768) {
    return 'is-small';
  } else if (windowWidth <= 1023) {
    return null;
  } else {
    return 'is-medium';
  }
}

function PositionIcon({ areas, coasts, positions, userGames, windowWidth }) {
  const areaName = snakeCase(areas[positions[0].area_id].name);
  const coastDirection = positions[0].coast_id && coasts[positions[0].coast_id].direction;
  const areaClass = coastDirection ? `${areaName}_${coastDirection}` : areaName;
  const iconModifier = calculateIconModifier(windowWidth);
  if (positions.length === 1) {
    const position = positions[0];
    const classNames = ['icon', 'icon-map', iconModifier, areaClass];
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
    const unitClassNames = ['icon', 'icon-map', iconModifier, areaClass, unitPower, unitPosition.type];
    const areaPosition = find(positions, position => !position.type || position.dislodged);
    if (!areaPosition) {
      debugger;
    }
    const areaPower = userGames[areaPosition.user_game_id].power;
    const areaClassNames = ['icon', 'icon-map', iconModifier, 'occupied-area', areaClass, areaPower];
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
  const [windowWidth, setWindowWidth] = useState(window.innerWidth);

  useEffect(() => {
    window.addEventListener('resize', () => {
      setWindowWidth(window.innerWidth);
    });
  }, []);

  return (
    <div className="container-map">
      <img src={props.map_path} />
      {props.positions.map(positions =>
        <PositionIcon
          key={positions[0].area_id}
          areas={props.areas}
          coasts={props.coasts}
          positions={positions}
          userGames={props.user_games}
          windowWidth={windowWidth} />
      )}
    </div>
  );
}
