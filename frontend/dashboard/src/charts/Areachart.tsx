import {AreaChart, Area, XAxis, YAxis, Tooltip, Legend } from 'recharts';

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

function Areachart() {
  

    return (
        <>
        <div className="w-[1168px] h-[430px] py-5 bg-[#121429] opacity-70 rounded-3xl">
        <div className="text-3xl text-center text-white-900">
            TVL over time
        </div>
        <div>
        <AreaChart 
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
        <defs>
            <linearGradient id="colorUv" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="#B341B1" stopOpacity={0.9}/>
            <stop offset="95%" stopColor="#B341B1" stopOpacity={0}/>
            </linearGradient>
        </defs>
        <XAxis dataKey="time" stroke="#D8D8D8" />
        <YAxis dataKey="TVL" stroke="#D8D8D8" />
        <Tooltip />
        <Area type="monotone" dataKey="TVL" stroke="#B341B1" strokeWidth={5} fillOpacity={1} fill="url(#colorUv)" />
        </AreaChart>
        </div>
        </div>

</>
)
}

export default Areachart;