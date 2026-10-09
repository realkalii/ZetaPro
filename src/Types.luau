export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Fire: (self: Signal<T...>, T...) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Icon = string | { Type: "Image" | "Url" | "Vector", Source: string?, Tint: boolean? }

export type Theme = {
	Background: Color3,
	SecondaryBackground: Color3,
	TertiaryBackground: Color3,
	Text: Color3,
	MutedText: Color3,
	Accent: Color3,
	AccentText: Color3,
	Border: Color3,
	Hover: Color3,
	Pressed: Color3,
	Success: Color3,
	Warning: Color3,
	Error: Color3,
	Info: Color3?,
	Overlay: Color3?,
	AcrylicTransparency: number?,
}

export type WindowConfig = {
	Title: string,
	SubTitle: string?,
	Icon: Icon?,
	Size: UDim2?,
	TabWidth: number?,
	MinSize: Vector2?,
	MaxSize: Vector2?,
	Theme: string?,
	Acrylic: boolean?,
	Blur: boolean?,
	Resize: boolean?,
	CloseButton: boolean?,
	OnClose: (() -> ())?,
	SearchEnabled: boolean?,
	MinimizeKey: Enum.KeyCode?,
}

export type TabConfig = { Title: string, Icon: Icon? }

export type BaseConfig = {
	Title: string?,
	Description: string?,
	Icon: Icon?,
	Tooltip: string?,
	Visible: boolean?,
	Enabled: boolean?,
}

export type ButtonConfig = BaseConfig & { Callback: (() -> ())? }
export type ToggleConfig = BaseConfig & { Default: boolean?, Callback: ((boolean) -> ())? }
export type SliderConfig = BaseConfig & {
	Min: number,
	Max: number,
	Default: number?,
	Increment: number?,
	Rounding: number?,
	Callback: ((number) -> ())?,
}
export type DropdownConfig = BaseConfig & {
	Values: { string },
	Multi: boolean?,
	Default: (string | number | { [string]: boolean })?,
	Callback: ((any) -> ())?,
}
export type InputConfig = BaseConfig & {
	Default: string?,
	Placeholder: string?,
	MaxLength: number?,
	Numeric: boolean?,
	Live: boolean?,
	Validate: ((string) -> boolean)?,
	Callback: ((string) -> ())?,
}
export type KeybindConfig = BaseConfig & {
	Default: (Enum.KeyCode | Enum.UserInputType | string)?,
	Callback: ((Enum.KeyCode | Enum.UserInputType) -> ())?,
	ChangedCallback: ((Enum.KeyCode | Enum.UserInputType) -> ())?,
}
export type ColorpickerConfig = BaseConfig & {
	Default: Color3?,
	Transparency: number?,
	Callback: ((Color3, number) -> ())?,
}
export type ParagraphConfig = { Title: string?, Content: string?, Icon: Icon?, RichText: boolean? }

export type NotificationConfig = {
	Title: string?,
	Content: string?,
	Type: ("Info" | "Success" | "Warning" | "Error")?,
	Duration: number?,
	Icon: Icon?,
	Progress: boolean?,
	Closable: boolean?,
}

export type Notification = { Close: (self: Notification) -> (), Closed: Signal<()> }

export type Component = {
	Kind: string,
	Id: string?,
	Frame: Frame?,
	GetValue: (self: Component) -> any,
	SetValue: (self: Component, value: any) -> (),
	OnChanged: (self: Component, callback: (...any) -> ()) -> Connection,
	SetTitle: (self: Component, text: string) -> (),
	SetDescription: (self: Component, text: string) -> (),
	SetIcon: (self: Component, icon: Icon?) -> (),
	SetVisible: (self: Component, visible: boolean) -> (),
	SetEnabled: (self: Component, enabled: boolean) -> (),
	SetTooltip: (self: Component, text: string) -> (),
	Destroy: (self: Component) -> (),
}

export type Section = {
	Title: string,
	SetTitle: (self: Section, text: string) -> (),
	Destroy: (self: Section) -> (),
	[string]: any,
}

export type Tab = {
	Title: string,
	Select: (self: Tab) -> (),
	Deselect: (self: Tab) -> (),
	SetTitle: (self: Tab, text: string) -> (),
	SetIcon: (self: Tab, icon: Icon?) -> (),
	AddSection: (self: Tab, title: string) -> Section,
	Destroy: (self: Tab) -> (),
	[string]: any,
}

export type Window = {
	Options: { [string]: Component },
	AddTab: (self: Window, config: TabConfig) -> Tab,
	SelectTab: (self: Window, tab: Tab | number | string) -> (),
	SetTitle: (self: Window, text: string) -> (),
	SetSubtitle: (self: Window, text: string?) -> (),
	SetTheme: (self: Window, name: string) -> boolean,
	SetSearchEnabled: (self: Window, enabled: boolean) -> (),
	CreateDialog: (self: Window, config: { Title: string, Content: string?, Buttons: { { Title: string, Callback: (() -> ())?, Primary: boolean? } }? }) -> any,
	Destroy: (self: Window) -> (),
}

return {}
