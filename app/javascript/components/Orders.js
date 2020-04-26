import React from 'react'

export default function Orders(props) {

  const areaMap = props.areas.reduce((map, area) => {
    return { ...map, [area.id]: area };
  }, {});

  return (
    <>
      <h2 className="subtitle is-5">Orders</h2>
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th>Unit</th>
            <th>Territory</th>
            <th>Order</th>
            <th>From</th>
            <th>To</th>
          </tr>
        </thead>
        <tbody>
          {props.positions.map((position) =>
            <tr key={position.id}>
              <td>{position.type}</td>
              <td>{areaMap[position.area_id].name}</td>
              <td></td>
              <td></td>
              <td></td>
            </tr>
          )}
        </tbody>
      </table>
    </>
  );
}
