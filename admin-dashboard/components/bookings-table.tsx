"use client"

import * as React from "react"
import {
  ColumnDef,
  ColumnFiltersState,
  SortingState,
  VisibilityState,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
} from "@tanstack/react-table"
import { 
  ArrowUpDown, 
  ChevronDown, 
  MoreHorizontal, 
  Search,
  Filter,
  Clock,
  CheckCircle2,
  XCircle,
  AlertCircle,
  CircleDashed
} from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Input } from "@/components/ui/input"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { format } from "date-fns"
import { srLatn } from "date-fns/locale"
import { cn } from "@/lib/utils"

import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { X } from "lucide-react"

// Mock Data
const data: Booking[] = [
  {
    id: "1",
    court: "Teren 1",
    player: "Marko Marković",
    phone: "+381 64 123 4567",
    date: new Date(2024, 11, 24),
    time: "09:00 - 10:30",
    status: "confirmed",
    paymentStatus: "paid",
    totalPrice: 4500,
  },
  {
    id: "2",
    court: "Teren 2",
    player: "Jovan Jovanović",
    phone: "+381 60 987 6543",
    date: new Date(2024, 11, 24),
    time: "10:30 - 12:00",
    status: "confirmed",
    paymentStatus: "unpaid",
    totalPrice: 5500,
  },
  {
    id: "3",
    court: "Teren 3",
    player: "Nikola Nikolić",
    phone: "+381 61 222 3333",
    date: new Date(2024, 11, 24),
    time: "09:00 - 11:00",
    status: "pending",
    paymentStatus: "unpaid",
    totalPrice: 6500,
  },
  {
    id: "4",
    court: "Teren 1",
    player: "Stefan Stević",
    phone: "+381 65 444 5555",
    date: new Date(2024, 11, 24),
    time: "17:00 - 18:00",
    status: "cancelled",
    paymentStatus: "refunded",
    totalPrice: 3500,
  },
  {
    id: "5",
    court: "Teren 4",
    player: "Petar Petrović",
    phone: "+381 63 777 8888",
    date: new Date(2024, 11, 24),
    time: "18:30 - 20:00",
    status: "completed",
    paymentStatus: "paid",
    totalPrice: 4500,
  },
]

export type Booking = {
  id: string
  court: string
  player: string
  phone: string
  date: Date
  time: string
  status: "pending" | "confirmed" | "cancelled" | "completed" | "no_show"
  paymentStatus: "unpaid" | "paid" | "refunded"
  totalPrice: number
}

export const columns: ColumnDef<Booking>[] = [
  {
    accessorKey: "player",
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          className="hover:bg-transparent p-0 font-semibold text-slate-900"
        >
          Igrač
          <ArrowUpDown className="ml-2 h-3 w-3" />
        </Button>
      )
    },
    cell: ({ row }) => (
      <div className="flex flex-col">
        <span className="font-semibold text-slate-900">{row.getValue("player")}</span>
        <span className="text-xs text-muted-foreground">{row.original.phone}</span>
      </div>
    ),
  },
  {
    accessorKey: "court",
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          className="hover:bg-transparent p-0 font-bold text-slate-500 uppercase tracking-tight text-[10px]"
        >
          Teren
          <ArrowUpDown className="ml-1 h-3 w-3" />
        </Button>
      )
    },
    cell: ({ row }) => (
      <span className="text-sm font-medium text-slate-600">
        {row.getValue("court")}
      </span>
    ),
  },
  {
    accessorKey: "date",
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          className="hover:bg-transparent p-0 font-bold text-slate-500 uppercase tracking-tight text-[10px]"
        >
          Datum i Vreme
          <ArrowUpDown className="ml-1 h-3 w-3" />
        </Button>
      )
    },
    cell: ({ row }) => {
      const date = row.getValue("date") as Date
      return (
        <div className="flex flex-col">
          <span className="text-sm font-semibold text-slate-900">
            {format(date, "dd.MM.yyyy", { locale: srLatn })}
          </span>
          <span className="text-xs text-muted-foreground flex items-center gap-1">
            <Clock className="size-3" /> {row.original.time}
          </span>
        </div>
      )
    },
  },
  {
    accessorKey: "status",
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          className="hover:bg-transparent p-0 font-bold text-slate-500 uppercase tracking-tight text-[10px]"
        >
          Status
          <ArrowUpDown className="ml-1 h-3 w-3" />
        </Button>
      )
    },
    cell: ({ row }) => {
      const status = row.getValue("status") as string
      
      const statusConfig: Record<string, { label: string, color: string, icon: any }> = {
        pending: { label: "Na čekanju", color: "bg-slate-50 text-slate-600 border-slate-200", icon: CircleDashed },
        confirmed: { label: "Potvrđeno", color: "bg-slate-900 text-white border-slate-900", icon: CheckCircle2 },
        cancelled: { label: "Otkazano", color: "bg-rose-50 text-rose-700 border-rose-100", icon: XCircle },
        completed: { label: "Završeno", color: "bg-slate-100 text-slate-700 border-slate-200", icon: CheckCircle2 },
        no_show: { label: "Nedolazak", color: "bg-gray-100 text-gray-700 border-gray-100", icon: AlertCircle },
      }

      const config = statusConfig[status] || statusConfig.pending
      const Icon = config.icon

      return (
        <Badge className={cn("rounded-md border font-medium px-2 py-0.5 flex items-center gap-1 w-fit shadow-none", config.color)}>
          <Icon className="size-3" />
          {config.label}
        </Badge>
      )
    },
  },
  {
    accessorKey: "paymentStatus",
    header: ({ column }) => {
      return (
        <Button
          variant="ghost"
          onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          className="hover:bg-transparent p-0 font-bold text-slate-500 uppercase tracking-tight text-[10px]"
        >
          Plaćanje
          <ArrowUpDown className="ml-1 h-3 w-3" />
        </Button>
      )
    },
    cell: ({ row }) => {
      const status = row.getValue("paymentStatus") as string
      
      const paymentConfig: Record<string, { label: string, color: string }> = {
        paid: { label: "Plaćeno", color: "text-slate-900" },
        unpaid: { label: "Neplaćeno", color: "text-rose-600" },
        refunded: { label: "Vraćeno", color: "text-slate-400" },
      }

      const config = paymentConfig[status] || paymentConfig.unpaid

      return (
        <div className="flex flex-col">
          <span className={cn("text-[10px] font-bold uppercase tracking-tight", config.color)}>
            {config.label}
          </span>
          <span className="text-sm font-bold text-slate-900">
            {row.original.totalPrice.toLocaleString("sr-RS")} RSD
          </span>
        </div>
      )
    },
  },
  {
    id: "actions",
    enableHiding: false,
    cell: ({ row }) => {
      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-8 w-8 p-0 hover:bg-slate-100 rounded-md">
              <span className="sr-only">Open menu</span>
              <MoreHorizontal className="h-4 w-4 text-slate-400" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="bg-white border-slate-200 rounded-lg shadow-lg w-48">
            <DropdownMenuLabel className="text-[10px] font-bold text-slate-400 uppercase tracking-wider p-3 pb-1">Akcije</DropdownMenuLabel>
            <DropdownMenuItem className="focus:bg-slate-50 focus:text-slate-900 cursor-pointer px-3 py-2 text-sm">
              Vidi detalje
            </DropdownMenuItem>
            <DropdownMenuItem className="focus:bg-slate-50 focus:text-slate-900 cursor-pointer px-3 py-2 text-sm">
              Izmeni rezervaciju
            </DropdownMenuItem>
            <DropdownMenuSeparator className="bg-slate-100" />
            <DropdownMenuItem className="text-rose-600 focus:bg-rose-50 focus:text-rose-600 cursor-pointer px-3 py-2 text-sm font-medium">
              Otkaži rezervaciju
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    },
  },
]

export function BookingsTable() {
  const [sorting, setSorting] = React.useState<SortingState>([])
  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
  const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
  const [rowSelection, setRowSelection] = React.useState({})

  const table = useReactTable({
    data,
    columns,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    state: {
      sorting,
      columnFilters,
      columnVisibility,
      rowSelection,
    },
  })

  return (
    <div className="w-full">
      <div className="flex flex-col md:flex-row items-center justify-between gap-4 p-4 border-b border-slate-100 bg-white">
        <div className="flex items-center gap-2 w-full md:w-auto">
          <div className="relative w-full md:w-72">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
            <Input
              placeholder="Pretraži igrača..."
              value={(table.getColumn("player")?.getFilterValue() as string) ?? ""}
              onChange={(event) =>
                table.getColumn("player")?.setFilterValue(event.target.value)
              }
              className="pl-9 bg-white border-slate-200 rounded-lg focus-visible:ring-slate-400 h-9 text-sm"
            />
          </div>
          <Popover>
            <PopoverTrigger asChild>
              <Button variant="outline" size="sm" className="rounded-lg border-slate-200 h-9 px-3 font-semibold text-slate-600 hover:bg-slate-50 relative">
                <Filter className="mr-2 h-3.5 w-3.5" />
                Filter
                {table.getState().columnFilters.length > 0 && (
                  <span className="absolute -top-1 -right-1 flex h-3 w-3 items-center justify-center rounded-full bg-primary text-[8px] font-bold text-white shadow-sm">
                    {table.getState().columnFilters.length}
                  </span>
                )}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-80 p-0 bg-white border-slate-200 rounded-xl shadow-lg" align="start">
              <div className="p-4 space-y-4">
                <div className="flex items-center justify-between">
                  <h4 className="font-bold text-sm text-slate-900 uppercase tracking-wider">Filteri</h4>
                  <Button 
                    variant="ghost" 
                    size="sm" 
                    onClick={() => table.resetColumnFilters()}
                    className="h-8 text-xs font-bold text-slate-400 hover:text-slate-900"
                  >
                    Poništi sve
                  </Button>
                </div>
                
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-slate-400 uppercase tracking-widest px-1">Teren</label>
                  <Select 
                    value={(table.getColumn("court")?.getFilterValue() as string) ?? "all"}
                    onValueChange={(value) => {
                      table.getColumn("court")?.setFilterValue(value === "all" ? "" : value)
                    }}
                  >
                    <SelectTrigger className="w-full rounded-lg border-slate-200 h-9 font-semibold text-slate-600 bg-white text-sm">
                      <SelectValue placeholder="Svi tereni" />
                    </SelectTrigger>
                    <SelectContent className="bg-white border-slate-200 rounded-lg">
                      <SelectItem value="all">Svi tereni</SelectItem>
                      <SelectItem value="Teren 1">Teren 1</SelectItem>
                      <SelectItem value="Teren 2">Teren 2</SelectItem>
                      <SelectItem value="Teren 3">Teren 3</SelectItem>
                      <SelectItem value="Teren 4">Teren 4</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-slate-400 uppercase tracking-widest px-1">Plaćanje</label>
                  <div className="grid grid-cols-2 gap-2">
                    {["paid", "unpaid"].map((status) => {
                      const isSelected = table.getColumn("paymentStatus")?.getFilterValue() === status
                      return (
                        <Button
                          key={status}
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            table.getColumn("paymentStatus")?.setFilterValue(isSelected ? "" : status)
                          }}
                          className={cn(
                            "rounded-lg border-slate-200 font-semibold text-xs transition-all",
                            isSelected ? "bg-slate-900 text-white border-slate-900" : "text-slate-600 hover:bg-slate-50"
                          )}
                        >
                          {status === 'paid' ? 'Plaćeno' : 'Neplaćeno'}
                        </Button>
                      )
                    })}
                  </div>
                </div>
              </div>
            </PopoverContent>
          </Popover>
        </div>
        
        <div className="flex items-center gap-2 w-full md:w-auto">
          <Select 
            value={(table.getColumn("status")?.getFilterValue() as string) ?? "all"}
            onValueChange={(value) => {
              table.getColumn("status")?.setFilterValue(value === "all" ? "" : value)
            }}
          >
            <SelectTrigger className="w-full md:w-[140px] rounded-lg border-slate-200 h-9 font-semibold text-slate-600 bg-white text-sm">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent className="bg-white border-slate-200 rounded-lg">
              <SelectItem value="all">Svi Statusi</SelectItem>
              <SelectItem value="confirmed">Potvrđeno</SelectItem>
              <SelectItem value="pending">Na čekanju</SelectItem>
              <SelectItem value="cancelled">Otkazano</SelectItem>
              <SelectItem value="completed">Završeno</SelectItem>
            </SelectContent>
          </Select>
          
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" className="rounded-lg border-slate-200 h-9 px-3 font-semibold text-slate-600 hover:bg-slate-50">
                Kolone <ChevronDown className="ml-1.5 h-3.5 w-3.5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="bg-white border-slate-200 rounded-lg shadow-lg">
              {table
                .getAllColumns()
                .filter((column) => column.getCanHide())
                .map((column) => {
                  return (
                    <DropdownMenuCheckboxItem
                      key={column.id}
                      className="capitalize text-sm font-medium focus:bg-slate-50 focus:text-slate-900"
                      checked={column.getIsVisible()}
                      onCheckedChange={(value) =>
                        column.toggleVisibility(!!value)
                      }
                    >
                      {column.id === 'player' ? 'Igrač' : 
                       column.id === 'court' ? 'Teren' : 
                       column.id === 'date' ? 'Datum' : 
                       column.id === 'status' ? 'Status' : 
                       column.id === 'paymentStatus' ? 'Plaćanje' : column.id}
                    </DropdownMenuCheckboxItem>
                  )
                })}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
      
      <div className="overflow-x-auto">
        <Table>
          <TableHeader className="bg-slate-50/50">
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id} className="hover:bg-transparent border-slate-100">
                {headerGroup.headers.map((header) => {
                  return (
                    <TableHead key={header.id} className="h-10 px-4 font-bold text-slate-500 uppercase tracking-tight text-[10px]">
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                    </TableHead>
                  )
                })}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow
                  key={row.id}
                  className="border-slate-50 hover:bg-slate-50/30 transition-colors"
                >
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id} className="px-4 py-3">
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center text-muted-foreground font-medium"
                >
                  Nema rezultata.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
      
      <div className="flex items-center justify-between p-4 border-t border-slate-100 bg-white">
        <div className="text-xs text-muted-foreground font-medium">
          Prikazano <span className="text-slate-900 font-bold">{table.getFilteredRowModel().rows.length}</span> od <span className="text-slate-900 font-bold">{data.length}</span> rezervacija
        </div>
        <div className="flex items-center space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
            className="h-8 rounded-md border-slate-200 font-semibold text-slate-600 text-xs"
          >
            Prethodna
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}
            className="h-8 rounded-md border-slate-200 font-semibold text-slate-600 text-xs"
          >
            Sledeća
          </Button>
        </div>
      </div>
    </div>
  )
}
