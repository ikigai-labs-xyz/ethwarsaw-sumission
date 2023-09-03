import './App.css'
import Sidebar from './components/Sidebar'
import Areachart from './charts/Areachart'
import health from './assets/health.svg'
import activity from './assets/activity.svg'
import toggle from './assets/toggle.svg'
import search from './assets/search.svg'

function App() {

  return (
    <>
    <div className="m-5 grid grid-cols-12 grid-rows-12 gap-4">

     
      <div className='col-start-1 col-span-3'>
      <Sidebar  />
      </div>

      <div className='col-start-4 col-span-8'>
        <div className="grid grid-rows-2 gap-5">
          <div className="row-start-1">
            <div className="flex flex-row justify-between items-start">
              <img className='' src={toggle} alt="" />
              <img className='pr-5'src={search} alt="" />
            </div>
          <Areachart  />
          </div>

          <div className="row-start-2">
          <div className="flex flex-row gap-5 items-start">
            <img className='h-[395px]' src={activity} alt="" />
            <img className=' h-[390px]' src={health} alt="" />
          </div>
          </div>
        </div>
      </div>

  
    
    </div>

    </>
  )
}

export default App
