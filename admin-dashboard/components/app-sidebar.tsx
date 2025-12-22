"use client"

import * as React from "react"
import Image from "next/image"
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
      isActive: true,
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
  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader className="h-24 flex items-center justify-center border-none pt-4">
        <div className="flex items-center gap-2 px-4 py-6">
          <div className="flex items-center justify-center group-data-[collapsible=icon]:hidden">
            <Image 
              src="/assets/padelspace_logo_nobg.png" 
              alt="PadelSpace Logo" 
              width={160} 
              height={60} 
              priority
              className="object-contain"
            />
          </div>
          <div className="hidden group-data-[collapsible=icon]:flex items-center justify-center p-2">
            <Image 
              src="/assets/padelspace_logo_nobg.png" 
              alt="PadelSpace Logo" 
              width={40} 
              height={40} 
              priority
              className="object-contain min-w-10"
            />
          </div>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarMenu className="px-2 pt-4">
          {data.navMain.map((item) => (
            <SidebarMenuItem key={item.title}>
              <SidebarMenuButton
                asChild
                isActive={item.isActive}
                tooltip={item.title}
                className="hover:bg-primary/10 hover:text-primary data-[active=true]:bg-primary data-[active=true]:text-white transition-all duration-200"
              >
                <a href={item.url}>
                  <item.icon />
                  <span className="font-medium">{item.title}</span>
                </a>
              </SidebarMenuButton>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
      </SidebarContent>
      <SidebarFooter>
        <div className="p-4 group-data-[collapsible=icon]:hidden">
          <div className="rounded-xl bg-primary/10 p-4 border border-primary/20">
            <p className="text-xs font-semibold text-primary uppercase tracking-wider mb-1">Status Sistema</p>
            <div className="flex items-center gap-2">
              <div className="size-2 rounded-full bg-primary animate-pulse" />
              <p className="text-sm font-medium text-white/80">Sve radi normalno</p>
            </div>
          </div>
        </div>
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}

