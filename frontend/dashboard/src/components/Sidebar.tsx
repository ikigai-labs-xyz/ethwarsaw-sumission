import dashboard from '../assets/icon_dashboard.svg';
import alert from '../assets/icon_alert.svg';
import firewall from '../assets/icon_firewall.svg';
import account from '../assets/icon_account.svg';
import settings from '../assets/icon_settings.svg';

function Sidebar() {
  

  return (
    <>
     <div className="w-[320px] h-[985px] bg-[#1D1429] opacity-70 rounded-3xl p-10">
        <div className="flex flex-col text-center items-center flex-start mb-12 text-white pl-7">
            <img className="mr-7" src={"https://uploads-ssl.webflow.com/649014d99c5194ad73558cd3/6490589d28c1d7f08f104851_Group%2047424.svg"} alt="Logo" />
            <span className="mr-7 mt-1 text-lg font-bold">Security Dashboard</span>
        </div>
        <div className="flex flex-col justify-between flex-1 pl-7">
            <ul className=" pr-7 list-none">
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                    <img src={dashboard} alt="" />
                        <span className="ml-2">Dashboard</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <img src={alert} alt="" />
                        <span className="ml-2">Alerts</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <img src={firewall} alt="" />
                        <span className="ml-2">Firewall Activity</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <img src={account} alt="" />
                        <span className="ml-2">Account</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <img src={settings} alt="" />
                        <span className="ml-2">Settings</span>
                    </a>
                </li>
            </ul>
        </div>



      
     </div>
    </>
  )
}

export default Sidebar;