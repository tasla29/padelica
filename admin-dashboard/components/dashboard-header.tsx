"use client"

import * as React from "react"
import { Search, Bell, User } from "lucide-react"
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
    <header className="sticky top-0 z-40 flex h-16 w-full items-center justify-between border-b border-white/5 bg-[#151c28] px-6 text-white">
      <div className="flex items-center gap-4">
        <SidebarTrigger className="-ml-1 text-white/70 hover:text-primary hover:bg-white/10" />
        <div className="hidden md:flex flex-col">
          <p className="text-sm font-semibold capitalize text-white">{formattedDate}</p>
          <p className="text-xs text-white/60 font-medium">{formattedTime}</p>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="relative hidden lg:block w-64">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-white/40" />
          <Input
            type="search"
            placeholder="Pretraži rezervacije..."
            className="w-full bg-white/5 border-none pl-9 focus-visible:ring-primary text-white placeholder:text-white/30"
          />
        </div>

        <Button variant="ghost" size="icon" className="relative text-white/70 hover:text-primary hover:bg-white/10">
          <Bell className="h-5 w-5" />
          <span className="absolute right-2 top-2 flex h-2 w-2 rounded-full bg-primary shadow-[0_0_8px_#FF0099]" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="relative h-10 w-10 rounded-full border-2 border-primary/20 p-0 hover:border-primary/50 transition-all">
              <Avatar className="h-9 w-9">
                <AvatarImage src="/avatars/admin.png" alt="Admin" />
                <AvatarFallback className="bg-primary/10 text-primary font-bold">AD</AvatarFallback>
              </Avatar>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent className="w-56 bg-[#1a2332] border-[#2d3a4f] text-white" align="end" forceMount>
            <DropdownMenuLabel className="font-normal">
              <div className="flex flex-col space-y-1">
                <p className="text-sm font-bold leading-none">Admin PadelSpace</p>
                <p className="text-xs leading-none text-white/60">admin@padelspace.rs</p>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator className="bg-[#2d3a4f]" />
            <DropdownMenuItem className="focus:bg-primary focus:text-white cursor-pointer transition-colors">Profil</DropdownMenuItem>
            <DropdownMenuItem className="focus:bg-primary focus:text-white cursor-pointer transition-colors">Podešavanja</DropdownMenuItem>
            <DropdownMenuSeparator className="bg-[#2d3a4f]" />
            <DropdownMenuItem className="text-red-400 focus:bg-red-500 focus:text-white cursor-pointer transition-colors">Odjavi se</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}

