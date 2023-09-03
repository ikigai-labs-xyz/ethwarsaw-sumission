import { LineChart, AreaChart, Area, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, Label, } from 'recharts';

const data = [
  {
    time: '12:00',
    TVL: 1200,
  },
  {
    time: '12:30',
    TVL: 3000,
  },
  {
    time: '13:00',
    TVL: 2000,
  },
  {
    time: '13:30',
    TVL: 2780,
  },
  {
    time: '14:00',
    TVL: 1890,
  },
  {
    time: '14:30',
    TVL: 2390,
  },
  {
    time: '15:00',
    TVL: 2000,
  },
  {
    time: '15:30',
    TVL: 2300,
  },
  {
    time: '16:00',
    TVL: 1490,
  },
  {
    time: '16:30',
    TVL: 2490,
  },
  {
    time: '17:00',
    TVL: 2200,
  },
  {
    time: '17:30',
    TVL: 3490,
  },
  {
    time: '18:00',
    TVL: 3200,
  },
];

function Linechart() {
  

    return (
      <>
       <div className="w-[1168px] h-[392px] py-5 bg-slate-800 opacity-70 rounded-3xl">
       <div className=''>
        <LineChart
          width={1150}
          height={350}
          data={data}
          margin={{
            top: 5,
            right: 30,
            left: 20,
            bottom: 5,
          }}
        >
          <CartesianGrid strokeDasharray="0 1" />
          <XAxis dataKey="time" />
          <YAxis dataKey="TVL" />
          <Tooltip />
          <Legend verticalAlign="top" height={36} stroke="#B341B1" />
          <Line type="monotone" dataKey="TVL" stroke="#B341B1" strokeWidth={5}  />
        </LineChart>
      </div>
       </div>

       
      </>
    )
  }
  
  export default Linechart;
  