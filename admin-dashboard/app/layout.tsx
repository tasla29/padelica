import type { Metadata } from "next";
import { Montserrat } from "next/font/google";
import "./globals.css";

const montserrat = Montserrat({
  variable: "--font-montserrat",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "PadelSpace Admin Dashboard",
  description: "Advanced booking management for PadelSpace center",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="bg-[#151c28] overflow-x-hidden">
      <body
        className={`${montserrat.variable} font-sans antialiased bg-[#151c28] text-foreground min-h-screen`}
      >
        <div className="bg-background min-h-screen">
          {children}
        </div>
      </body>
    </html>
  );
}
