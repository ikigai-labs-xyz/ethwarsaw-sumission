function Sidebar() {
  

  return (
    <>
     <div className="w-[320px] h-[985px] py-5 bg-slate-800 opacity-70 rounded-3xl m-5 p-10">
        <div className="flex flex-col text-center items-center flex-start mb-12 text-white pl-7 bg-inherit ">
            <img className="mr-7" src={"https://uploads-ssl.webflow.com/649014d99c5194ad73558cd3/6490589d28c1d7f08f104851_Group%2047424.svg"} alt="Logo" />
            <span className="mr-7 mt-1 text-lg font-bold">Security Dashboard</span>
        </div>
        <div className="flex flex-col justify-between flex-1 pl-7">
            <ul className=" pr-7 list-none">
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <span className="ml-2 ">...</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <span className="ml-2">...</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <span className="ml-2">...</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">

                        <span className="ml-2">...</span>
                    </a>
                </li>
                <li>
                    <a className="px-2 py-2 my-2 flex items-center text-white active:bg-blue-500 hover:bg-blue-900 rounded-md cursor-pointer">
                        <span className="ml-2">...</span>
                    </a>
                </li>
            </ul>
        </div>




      <div className="justify-center text-slate-300">
        Sidebar
      </div>
      
     </div>
    </>
  )
}

export default Sidebar;