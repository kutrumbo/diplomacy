import React, { useEffect, useState, } from 'react'
import { camelCase, capitalize, compact, groupBy, map, reduce, startCase } from 'lodash';

function formatTurnLabel(turn) {
  return `${startCase(camelCase(turn.type))} - ${1901 + Math.floor(turn.number / 5)}`
}

function formatPower(userGameIdString, userGames) {
  return capitalize(userGames[parseInt(userGameIdString, 10)].power);
}

function formatLocationName(area, coast) {
  if (!area) {
    return null;
  }
  if (coast) {
    const coastInitial = coast.direction.charAt(0).toUpperCase();
    return `${area.name} (${coastInitial}C)`;
  } else {
    return area.name;
  }
}

function formatResolution(resolution, areas, coasts) {
  const order = resolution[0];
  const status = capitalize(resolution[1]);
  const position = resolution[2];

  const unitType = position.type && capitalize(position.type);
  const loc = formatLocationName(areas[position.area_id], coasts[position.coast_id]);
  const fromLoc = formatLocationName(areas[order.from_id], coasts[order.from_coast_id]);
  const toLoc = formatLocationName(areas[order.to_id], coasts[order.to_coast_id]);

  switch(order.type) {
    case 'hold':
      return `${unitType} ${loc} hold - ${status}`;
    case 'build_fleet':
      return `Build fleet in ${toLoc}`;
    case 'build_army':
      return `Build army in ${loc}`;
    case 'move':
      return `${unitType} ${loc} move to ${toLoc} - ${status}`;
    case 'support':
      return `${unitType} ${loc} support ${fromLoc} to ${toLoc} - ${status}`;
    case 'convoy':
      return `${unitType} ${loc} convoy ${fromLoc} to ${toLoc} - ${status}`;
    case 'retreat':
      return `${unitType} ${loc} retreat to ${toLoc} - ${status}`;
    case 'disband':
      return `${unitType} ${loc} disbanded`;
    case 'keep':
    case 'no_build':
      return null;
    default:
      return null;
  }
}

async function fetchResolutions(gameId, turnId, setLoading, setResolutions) {
  setLoading(true);
  fetch(`/games/${gameId}/turns/${turnId}/orders`)
  .then(response => {
    if (!response.ok) {
      throw response;
    }
    return response.json()
  })
  .then(json => {
    setResolutions(json);
    setLoading(false);
  })
  .catch(error => {
    setLoading(false);
    console.error(error);
  });
}

export default function OrderHistory(props) {
  const [loading, setLoading] = useState(true);
  const [resolutions, setResolutions] = useState([]);
  const [turnId, setTurnId] = useState(props.turns[0].id);

  useEffect(() => {
    fetchResolutions(props.game.id, turnId, setLoading, setResolutions);
  }, [turnId]);

  const handleSelect = (event) => {
    setTurnId(event.target.value);
  };

  const groupedResolutions = groupBy(resolutions, resolution => resolution[0].user_game_id);
  const parsedResolutions = reduce(groupedResolutions, (result, resolutions, userGameId) => {
    const formattedResolutions = map(resolutions, resolution => formatResolution(resolution, props.areas, props.coasts));
    result.push([userGameId, compact(formattedResolutions)]);
    return result;
  }, []);

  return (
    <>
      <div className="select">
        <select value={turnId} onChange={handleSelect}>
          {props.turns.map(turn =>
            <option key={turn.id} value={turn.id}>{formatTurnLabel(turn)}</option>
          )}
        </select>
      </div>
      {loading && <p>Loading...</p>}
      {!loading && parsedResolutions.map(group =>
        <div key={group[0]}>
          <p className="has-text-weight-bold">{formatPower(group[0], props.user_games)}</p>
          <ul>
            {group[1].map(formattedResolution =>
              <li key={formattedResolution}>{formattedResolution}</li>
            )}
          </ul>
        </div>
      )}
    </>
  );
}
