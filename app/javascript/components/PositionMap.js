import React from 'react'
import { snakeCase, values } from 'lodash';

function PositionIcon({ areas, position, userGames }) {
  const power = userGames[position.user_game_id].power;
  const classNames = ['icon', 'icon-map', 'is-medium', power, snakeCase(areas[position.area_id].name)];
  if (position.type) {
    classNames.push(position.type);
  }
  if (position.power == power) {
    classNames.push('occupied');
  }
  return (
    <span className={classNames.join(' ')} />
  );
}

export default function PositionMap(props) {
  return (
    <div className="container-map">
      <img src={props.map_path} />
      {values(props.positions).map(position =>
        <PositionIcon key={position.id} position={position} areas={props.areas} userGames={props.user_games} />
      )}
    </div>
  );
}
