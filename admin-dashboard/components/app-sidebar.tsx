"use client"

import * as React from "react"
import Image from "next/image"
import { usePathname } from "next/navigation"
import {
  LayoutDashboard,
  CalendarDays,
  Users,
  BarChart3,
  Settings,
  Zap,
} from "lucide-react"

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail,
} from "@/components/ui/sidebar"

const data = {
  navMain: [
    {
      title: "Dashboard",
      url: "/",
      icon: LayoutDashboard,
    },
    {
      title: "Rezervacije",
      url: "/bookings",
      icon: CalendarDays,
    },
    {
      title: "Korisnici",
      url: "/customers",
      icon: Users,
    },
    {
      title: "Tereni",
      url: "/courts",
      icon: Zap,
    },
    {
      title: "Analitika",
      url: "/analytics",
      icon: BarChart3,
    },
    {
      title: "Podešavanja",
      url: "/settings",
      icon: Settings,
    },
  ],
}

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const pathname = usePathname()

  return (
    <Sidebar collapsible="icon" {...props} className="border-r border-slate-800">
      <SidebarHeader className="h-20 flex items-center justify-center border-none">
        <div className="flex items-center gap-2 px-4">
          <div className="flex items-center justify-center group-data-[collapsible=icon]:hidden">
            <Image 
              src="/assets/padelspace_logo_nobg.png" 
              alt="PadelSpace Logo" 
              width={130} 
              height={50} 
              priority
              className="object-contain"
            />
          </div>
          <div className="hidden group-data-[collapsible=icon]:flex items-center justify-center p-2">
            <Image 
              src="/assets/padelspace_logo_nobg.png" 
              alt="PadelSpace Logo" 
              width={32} 
              height={32} 
              priority
              className="object-contain min-w-8"
            />
          </div>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarMenu className="px-3 pt-2">
          {data.navMain.map((item) => {
            const isActive = pathname === item.url || (item.url !== "/" && pathname?.startsWith(item.url))
            
            return (
              <SidebarMenuItem key={item.title}>
                <SidebarMenuButton
                  asChild
                  isActive={isActive}
                  tooltip={item.title}
                  className="hover:bg-white/5 hover:text-white data-[active=true]:bg-primary data-[active=true]:text-white transition-all duration-150 rounded-lg h-10 px-3"
                >
                  <a href={item.url}>
                    <item.icon className="size-4" />
                    <span className="font-semibold text-sm">{item.title}</span>
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
            )
          })}
        </SidebarMenu>
      </SidebarContent>
      <SidebarFooter>
        <div className="p-4 group-data-[collapsible=icon]:hidden">
          <div className="rounded-lg bg-white/5 p-3 border border-white/10">
            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-1">Status Sistema</p>
            <div className="flex items-center gap-2">
              <div className="size-1.5 rounded-full bg-emerald-500" />
              <p className="text-xs font-medium text-slate-300">Online</p>
            </div>
          </div>
        </div>
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}
