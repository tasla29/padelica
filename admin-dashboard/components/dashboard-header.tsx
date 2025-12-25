"use client"

import * as React from "react"
import { Search, Bell } from "lucide-react"
import { Input } from "@/components/ui/input"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { SidebarTrigger } from "@/components/ui/sidebar"

export function DashboardHeader() {
  const [dateTime, setDateTime] = React.useState(new Date())

  React.useEffect(() => {
    const timer = setInterval(() => setDateTime(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  const formattedDate = dateTime.toLocaleDateString("sr-Latn-RS", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  })

  const formattedTime = dateTime.toLocaleTimeString("sr-Latn-RS", {
    hour: "2-digit",
    minute: "2-digit",
  })

  return (
    <header className="sticky top-0 z-40 flex h-14 w-full items-center justify-between border-b border-slate-200 bg-white px-6">
      <div className="flex items-center gap-4">
        <SidebarTrigger className="-ml-1 text-slate-500 hover:text-slate-900 hover:bg-slate-100" />
        <div className="hidden md:flex flex-col">
          <p className="text-xs font-semibold capitalize text-slate-700">{formattedDate}</p>
          <p className="text-[10px] text-slate-400 font-medium">{formattedTime}</p>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="relative hidden lg:block w-64">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
          <Input
            type="search"
            placeholder="Pretraži..."
            className="w-full bg-slate-50 border-slate-200 pl-9 focus-visible:ring-slate-400 text-sm h-9"
          />
        </div>

        <Button variant="ghost" size="icon" className="relative text-slate-500 hover:text-slate-900 hover:bg-slate-100 h-9 w-9">
          <Bell className="h-4 w-4" />
          <span className="absolute right-2.5 top-2.5 flex h-1.5 w-1.5 rounded-full bg-primary" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="relative h-8 w-8 rounded-full border border-slate-200 p-0 hover:bg-slate-50 transition-all">
              <Avatar className="h-7 w-7">
                <AvatarImage src="/avatars/admin.png" alt="Admin" />
                <AvatarFallback className="bg-slate-100 text-slate-600 text-[10px] font-bold">AD</AvatarFallback>
              </Avatar>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent className="w-56 bg-white border-slate-200 shadow-lg" align="end" forceMount>
            <DropdownMenuLabel className="font-normal">
              <div className="flex flex-col space-y-1">
                <p className="text-sm font-bold leading-none text-slate-900">Admin PadelSpace</p>
                <p className="text-xs leading-none text-slate-500">admin@padelspace.rs</p>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator className="bg-slate-100" />
            <DropdownMenuItem className="focus:bg-slate-50 cursor-pointer transition-colors text-sm">Profil</DropdownMenuItem>
            <DropdownMenuItem className="focus:bg-slate-50 cursor-pointer transition-colors text-sm">Podešavanja</DropdownMenuItem>
            <DropdownMenuSeparator className="bg-slate-100" />
            <DropdownMenuItem className="text-rose-600 focus:bg-rose-50 cursor-pointer transition-colors text-sm font-medium">Odjavi se</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
